// SPDX-FileCopyrightText: Copyright Logically Magic Inc. <hello@logicallymagic.com>
// SPDX-FileCopyrightText: Copyright Hamid Jahanzad <Hamid@Jahanzad.com>
// SPDX-FileCopyrightText: Copyright Contributors to the Bank8:EFintech
// SPDX-License-Identifier: Apache-2.0

// eFintech BFF scope whitelist configuration
// BFF scope whitelist per app instance.
// eFintech only needs FDX recipient scopes + DB/Buck - no Ledger/Payments (read-only recipient).

/// ScopeWhitelist defines the allowed scopes and services for eFintech BFF instances.
#[derive(Debug, Clone)]
pub struct ScopeWhitelist {
    pub app_slug: String,
    pub allowed_scopes: Vec<String>,
    pub allowed_services: Vec<String>,
}

pub static E_FINTECH_SCOPE_WHITELIST: ScopeWhitelist = ScopeWhitelist {
    app_slug: "efintech".to_string(),
    allowed_scopes: vec![
        "openid".to_string(),
        "profile".to_string(),
        "email".to_string(),
        "bank8:fdx:recipient:read".to_string(),
        "bank8:fdx:recipient:write".to_string(),
        "db:data:read".to_string(),
        "db:data:write".to_string(),
        "storage:env:read".to_string(),
        "storage:env:write".to_string(),
    ],
    allowed_services: vec![
        "fdx".to_string(),
        "db".to_string(),
        "storage".to_string(),
    ],
};