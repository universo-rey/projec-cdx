import json
import sys
from pathlib import Path

try:
    from jsonschema import Draft7Validator, Draft202012Validator
except Exception as exc:
    print("jsonschema_not_available:" + str(exc))
    sys.exit(5)


def main() -> int:
    if len(sys.argv) != 3:
        print("usage: ceo-jsonschema-validate.py <json-file> <schema-file>")
        return 5

    json_file = Path(sys.argv[1])
    schema_file = Path(sys.argv[2])
    data = json.loads(json_file.read_text(encoding="utf-8-sig"))
    schema = json.loads(schema_file.read_text(encoding="utf-8-sig"))
    schema_uri = schema.get("$schema", "")
    validator_cls = Draft202012Validator if "2020-12" in schema_uri else Draft7Validator
    errors = sorted(validator_cls(schema).iter_errors(data), key=lambda item: list(item.path))
    if errors:
        first = errors[0]
        path = ".".join(str(part) for part in first.path) or "<root>"
        print(path + ":" + first.message)
        return 1

    print("VALID")
    return 0


if __name__ == "__main__":
    sys.exit(main())
