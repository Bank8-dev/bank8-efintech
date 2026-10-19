#!/usr/bin/env bash
# SPDX-FileCopyrightText: Copyright Logically Magic Inc. <hello@logicallymagic.com>
# SPDX-FileCopyrightText: Copyright Hamid Jahanzad <Hamid@Jahanzad.com>
# SPDX-FileCopyrightText: Copyright Contributors to the Bank8:EFintech
# SPDX-License-Identifier: Apache-2.0
# eFintech CI Guard - detect prohibited patterns in eFintech code.
set -euo pipefail
EBANK_DIR="$(cd "$(dirname "$0")" && pwd)"
VIOLATIONS=0
echo "🔍 Running eFintech CI guards..."

if grep -r --include='*.dart' --include='*.rs' -l 'postgres\|pgx\|tokio-postgres\|diesel\|sqlx::PgPool\|PgPoolOptions' "$EBANK_DIR/lib" "$EBANK_DIR/bff" 2>/dev/null; then echo "❌ Direct PostgreSQL driver usage"; VIOLATIONS=$((VIOLATIONS + 1)); fi
if grep -r --include='*.dart' --include='*.rs' -l 'SELECT.*FROM\|INSERT.*INTO\|UPDATE.*SET\|DELETE.*FROM' "$EBANK_DIR/lib" "$EBANK_DIR/bff" 2>/dev/null; then echo "❌ Raw SQL queries"; VIOLATIONS=$((VIOLATIONS + 1)); fi
if grep -r --include='*.dart' --include='*.rs' -l 'diesel\|sea-orm\|sqlx\|rbatis\|ormx' "$EBANK_DIR/lib" "$EBANK_DIR/bff" 2>/dev/null; then echo "❌ ORM usage"; VIOLATIONS=$((VIOLATIONS + 1)); fi
if grep -r --include='*.dart' --include='*.rs' -l 'aws-sdk-rust\|aws-sdk-s3\|minio-rs\|cloud-storage\|azure-storage\|reqwest.*s3\|S3Client' "$EBANK_DIR/lib" "$EBANK_DIR/bff" 2>/dev/null; then echo "❌ Direct object storage SDK usage"; VIOLATIONS=$((VIOLATIONS + 1)); fi
if grep -r --include='*.dart' --include='*.rs' -l 'sentin8-config\|sentin8_config' "$EBANK_DIR/lib" "$EBANK_DIR/bff" 2>/dev/null; then echo "❌ @sentin8/sentin8-config import"; VIOLATIONS=$((VIOLATIONS + 1)); fi
if grep -r --include='*.dart' --include='*.rs' -l 'eyJ[A-Za-z0-9_-]*\.eyJ' "$EBANK_DIR/lib" "$EBANK_DIR/bff" 2>/dev/null; then echo "❌ JWT-like string in source"; VIOLATIONS=$((VIOLATIONS + 1)); fi
# eFintech-specific: no direct external provider calls (must go through Bank8:FDX)
if grep -r --include='*.dart' -l 'https://.*\.\(bank\|fintech\)\.' "$EBANK_DIR/lib" 2>/dev/null | grep -v 'test/' | grep -v 'bff'; then echo "❌ Direct external provider call (must go through Bank8:FDX)"; VIOLATIONS=$((VIOLATIONS + 1)); fi
if grep -r --include='*.dart' --include='*.rs' --include='*.yaml' --include='*.json' -l 'password\s*[:=]\s*["\x27][^"\x27]' "$EBANK_DIR/lib" "$EBANK_DIR/bff" 2>/dev/null; then echo "❌ Plaintext secret detected"; VIOLATIONS=$((VIOLATIONS + 1)); fi

if [ $VIOLATIONS -gt 0 ]; then echo "❌ $VIOLATIONS CI guard violation(s) found."; exit 1; fi
echo "✅ All CI guards passed."