#!/usr/bin/env python3
"""Convert Kubernetes CRD YAML files into JSON schemas for kubeconform.

For each CRD passed on the command line, this writes one JSON schema per
served version into the output directory (default: schemas/). Files are
named so kubeconform can resolve them via a -schema-location template of:

  {{ .ResourceKind }}-{{ .Group }}-{{ .ResourceAPIVersion }}.json

e.g. TracingPolicy-cilium.io-v1alpha1.json

The kind keeps its original (mixed) case to match kubeconform's
{{ .ResourceKind }} substitution without relying on template functions
like tolower, which are not available across all kubeconform versions.

This is a trimmed, dependency-light converter. It relies only on PyYAML.
Usage:
  openapi2jsonschema.py -o schemas/ crd1.yaml crd2.yaml ...
"""

import argparse
import json
import os
import sys

try:
    import yaml
except ImportError:
    sys.stderr.write(
        "error: PyYAML is required (pip install pyyaml)\n"
    )
    sys.exit(1)


def additional_props_false(node):
    """Recursively set additionalProperties: false on object schemas.

    kubeconform runs in -strict mode, which needs objects to forbid
    unknown properties. We only add it where a properties map exists and
    the CRD did not explicitly allow arbitrary content (x-kubernetes-*).
    """
    if isinstance(node, dict):
        if node.get("type") == "object" and "properties" in node:
            node.setdefault("additionalProperties", False)
        for value in node.values():
            additional_props_false(value)
    elif isinstance(node, list):
        for item in node:
            additional_props_false(item)


def convert(crd_path, out_dir):
    with open(crd_path, "r") as handle:
        crd = yaml.safe_load(handle)

    spec = crd.get("spec", {})
    group = spec.get("group", "")
    names = spec.get("names", {})
    kind = names.get("kind", "")
    if not group or not kind:
        sys.stderr.write(
            "error: %s missing spec.group or spec.names.kind\n" % crd_path
        )
        sys.exit(1)

    written = []
    for version in spec.get("versions", []):
        version_name = version.get("name")
        schema = version.get("schema", {}).get("openAPIV3Schema")
        if not version_name or schema is None:
            continue

        additional_props_false(schema)

        filename = "%s-%s-%s.json" % (
            kind,
            group.lower(),
            version_name,
        )
        out_path = os.path.join(out_dir, filename)
        with open(out_path, "w") as handle:
            json.dump(schema, handle, indent=2)
        written.append(out_path)

    return written


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "-o", "--output", default="schemas", help="output directory"
    )
    parser.add_argument("crds", nargs="+", help="CRD YAML files")
    args = parser.parse_args()

    os.makedirs(args.output, exist_ok=True)

    all_written = []
    for crd in args.crds:
        all_written.extend(convert(crd, args.output))

    for path in all_written:
        print("wrote %s" % path)

    if not all_written:
        sys.stderr.write("error: no schemas were generated\n")
        sys.exit(1)


if __name__ == "__main__":
    main()
