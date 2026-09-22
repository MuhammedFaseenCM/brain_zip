"""Upload Google Play Data safety labels via the Android Publisher API."""

from __future__ import annotations

import sys
from pathlib import Path

from google.oauth2 import service_account
from googleapiclient.discovery import build
from googleapiclient.errors import HttpError

ROOT = Path(__file__).resolve().parents[1]
PACKAGE_NAME = "com.winklo.faseencm"
JSON_KEY = ROOT / "play/play-service-account.json"
CSV_PATH = ROOT / "play/data_safety.csv"
SCOPES = ["https://www.googleapis.com/auth/androidpublisher"]


def main() -> int:
  if not JSON_KEY.is_file():
    print(f"Missing service account key: {JSON_KEY}", file=sys.stderr)
    return 1
  if not CSV_PATH.is_file():
    print(f"Missing Data safety CSV: {CSV_PATH}", file=sys.stderr)
    return 1

  credentials = service_account.Credentials.from_service_account_file(
      JSON_KEY,
      scopes=SCOPES,
  )
  service = build("androidpublisher", "v3", credentials=credentials)
  try:
    service.applications().dataSafety(
        packageName=PACKAGE_NAME,
        body={"safetyLabels": CSV_PATH.read_text(encoding="utf-8")},
    ).execute()
  except HttpError as error:
    print(error.content.decode(), file=sys.stderr)
    return 1

  print(f"Uploaded Data safety labels for {PACKAGE_NAME}")
  return 0


if __name__ == "__main__":
  raise SystemExit(main())
