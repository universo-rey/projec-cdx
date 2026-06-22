from __future__ import annotations

from projec_cdx_common.safe_errors import sanitize_exception_message


def test_sanitize_exception_message_redacts_common_secret_shapes() -> None:
    openai_token = "sk-" + ("a" * 32)
    github_token = "ghp_" + ("b" * 24)
    openai_key_name = "OPENAI_API" + "_KEY"
    message = sanitize_exception_message(
        f"failed {openai_key_name}={openai_token} token={github_token}"
    )

    assert openai_token not in message
    assert github_token not in message
    assert "[REDACTED" in message


def test_sanitize_exception_message_keeps_safe_context() -> None:
    message = sanitize_exception_message("metadata file not found")

    assert message == "metadata file not found"
