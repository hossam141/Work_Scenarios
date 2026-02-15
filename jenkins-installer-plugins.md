# Task Assignment: Jenkins Plugin Installer Script Analysis

---

## 📋 Task Details

| Field | Details |
|-------|---------|
| **Assigned To** | DevOps Engineer |
| **Assigned By** | Team Lead |
| **Priority** | High |
| **Due Date** | February 15, 2026 |
| **Status** | ✅ Completed |

---

## 📝 Task Description

> **"We have two files in our CI/CD pipeline setup — `installer.sh` and `plugins.txt`. Please review both files, break down what the script does step by step, explain the authentication mechanism, document all the plugins being installed and their purpose, and flag any security concerns or issues. Deliver a clear technical document that the rest of the team can reference."**

---

## 📌 Deliverable

---

# Jenkins Plugin Installer — Technical Documentation

**Author:** DevOps Engineer
**Date:** February 15, 2026
**Version:** 1.0

---

## 1. Executive Summary

The `installer.sh` script automates the installation of 9 Jenkins plugins using the Jenkins REST API. It authenticates against a local Jenkins instance, generates an API token, then iterates through `plugins.txt` to install each plugin with its pinned version. This document provides a full breakdown of the script logic, authentication flow, plugin inventory, and identified risks.

---

## 2. Files Under Review

| File | Type | Purpose |
|------|------|---------|
| `installer.sh` | Bash Script | Handles authentication and plugin installation via Jenkins API |
| `plugins.txt` | Text File | Lists 9 plugins with pinned versions (format: `name@version`) |

---

## 3. Script Breakdown — `installer.sh`

### 3.1 Error Handling Configuration

```bash
#!/bin/bash
set -eo pipefail
```

- **`set -e`** — Script exits immediately if any command returns a non-zero exit code
- **`set -o pipefail`** — A pipeline fails if any command in the pipe fails, not just the last one
- **Impact:** Prevents silent failures. If authentication fails, the script stops before attempting plugin installs

### 3.2 Jenkins URL Definition

```bash
JENKINS_URL='http://localhost:8080'
```

- Targets a Jenkins instance running locally on the default port
- Assumes the script is executed directly on the Jenkins server or a machine with localhost access

### 3.3 CSRF Crumb Retrieval

```bash
JENKINS_CRUMB=$(curl -s --cookie-jar /tmp/cookies \
  -u admin:admin \
  ${JENKINS_URL}/crumbIssuer/api/json | jq .crumb -r)
```

- **What it does:** Fetches a CSRF protection token from Jenkins
- **Authentication:** Uses default `admin:admin` credentials (basic auth)
- **Cookie handling:** Saves the session cookie to `/tmp/cookies` for reuse
- **JSON parsing:** Extracts the `.crumb` field from the API response using `jq`
- **Why it's needed:** Jenkins requires a valid crumb on every POST request to prevent Cross-Site Request Forgery attacks

### 3.4 API Token Generation

```bash
JENKINS_TOKEN=$(curl -s -X POST \
  -H "Jenkins-Crumb:${JENKINS_CRUMB}" \
  --cookie /tmp/cookies \
  "${JENKINS_URL}/me/descriptorByName/jenkins.security.ApiTokenProperty/generateNewToken?newTokenName=demo-token66" \
  -u admin:admin | jq .data.tokenValue -r)
```

- **What it does:** Creates a new API token named `demo-token66`
- **Headers:** Includes the CSRF crumb from the previous step
- **Cookies:** Reuses the session cookie from `/tmp/cookies`
- **JSON parsing:** Extracts `.data.tokenValue` from the response
- **Purpose:** The generated token replaces password-based auth for subsequent API calls

### 3.5 Debug Output

```bash
echo $JENKINS_URL
echo $JENKINS_CRUMB
echo $JENKINS_TOKEN
```

- Prints the URL, crumb, and token to stdout for verification
- **⚠️ Security concern:** The API token is printed in cleartext to the terminal and could be captured in logs

### 3.6 Plugin Installation Loop

```bash
while read plugin; do
   echo "........Installing ${plugin} .."
   curl -s POST --data "<jenkins><install plugin='${plugin}' /></jenkins>" \
     -H 'Content-Type: text/xml' \
     "$JENKINS_URL/pluginManager/installNecessaryPlugins" \
     --user "admin:$JENKINS_TOKEN"
done < plugins.txt
```

- **Loop:** Reads each line from `plugins.txt` one at a time
- **XML payload:** Wraps the plugin name@version in a Jenkins-specific XML install request
- **Endpoint:** Sends to `/pluginManager/installNecessaryPlugins`
- **Auth:** Uses admin username paired with the generated API token
- **Progress:** Prints each plugin name as it processes

---

## 4. Authentication Flow Diagram

```
┌──────────────┐              ┌──────────────┐              ┌──────────────────┐
│ installer.sh │              │   Jenkins    │              │  Plugin Manager  │
│   (client)   │              │    :8080     │              │                  │
└──────┬───────┘              └──────┬───────┘              └────────┬─────────┘
       │                             │                               │
       │  ① GET /crumbIssuer         │                               │
       │  (auth: admin:admin)        │                               │
       │────────────────────────────>│                               │
       │                             │                               │
       │  ② Response: CSRF crumb     │                               │
       │     + session cookie        │                               │
       │<────────────────────────────│                               │
       │                             │                               │
       │  ③ POST /generateNewToken   │                               │
       │  (header: Jenkins-Crumb)    │                               │
       │  (cookie: session)          │                               │
       │────────────────────────────>│                               │
       │                             │                               │
       │  ④ Response: API token      │                               │
       │     "demo-token66"          │                               │
       │<────────────────────────────│                               │
       │                             │                               │
       │  ⑤ POST XML install request │                               │
       │  (auth: admin + API token)  │                               │
       │────────────────────────────>│──── Install plugin ──────────>│
       │                             │                               │
       │         (repeats for each of the 9 plugins)                 │
       │                             │                               │
```

---

## 5. Execution Flow Diagram

```
                         ┌─────────────────┐
                         │   START SCRIPT   │
                         └────────┬────────┘
                                  │
                                  ▼
                    ┌──────────────────────────┐
                    │  set -eo pipefail        │
                    │  Enable strict errors    │
                    └────────────┬─────────────┘
                                 │
                                 ▼
                    ┌──────────────────────────┐
                    │  Set JENKINS_URL         │
                    │  http://localhost:8080   │
                    └────────────┬─────────────┘
                                 │
                                 ▼
                    ┌──────────────────────────┐
                    │  GET CSRF Crumb          │
                    │  /crumbIssuer/api/json   │
                    │  Save cookies            │
                    └────────────┬─────────────┘
                                 │
                                 ▼
                    ┌──────────────────────────┐
                    │  POST Generate API Token │
                    │  Token: "demo-token66"   │
                    └────────────┬─────────────┘
                                 │
                                 ▼
                    ┌──────────────────────────┐
                    │  Print URL, Crumb, Token │
                    │  (debug output)          │
                    └────────────┬─────────────┘
                                 │
                                 ▼
  ┌─────────────┐  ┌──────────────────────────────────┐
  │ plugins.txt │─>│  LOOP: Read each plugin           │◄──┐
  │  (9 lines)  │  │  POST XML → installNecessaryPlugins│   │ next
  └─────────────┘  └──────────────────┬─────────────────┘───┘
                                      │ (all done)
                                      ▼
                         ┌─────────────────┐
                         │   SCRIPT DONE   │
                         └─────────────────┘
```

---

## 6. Plugin Inventory — `plugins.txt`

### 6.1 CI/CD & Pipeline Plugins

| Plugin | Version | What It Does |
|--------|---------|--------------|
| `docker-workflow` | 1.26 | Allows Jenkins pipelines to build, run, and push Docker containers using `docker.image()` and `docker.build()` syntax |
| `blueocean` | 1.24.7 | Provides a modern, visual UI for creating, viewing, and editing Jenkins pipelines with a graphical pipeline editor |
| `kubernetes-cli` | 1.10.2 | Enables `kubectl` commands directly inside Jenkins pipeline steps for deploying to Kubernetes clusters |

### 6.2 Code Quality & Security Plugins

| Plugin | Version | What It Does |
|--------|---------|--------------|
| `sonar` | 2.13.1 | Integrates with SonarQube server for static code analysis, code smells, bugs, and technical debt tracking |
| `jacoco` | 3.2.0 | Collects and publishes JaCoCo code coverage reports showing line, branch, and method coverage for Java projects |
| `dependency-check` | 5.1.1 | Runs OWASP Dependency-Check scans to identify known vulnerabilities (CVEs) in project dependencies |
| `pitmutation` | 1.0-18 | Displays PIT mutation testing reports that measure how effectively your tests catch injected code faults |

### 6.3 Monitoring & Notification Plugins

| Plugin | Version | What It Does |
|--------|---------|--------------|
| `performance` | 3.18 | Parses performance test results (JMeter, Gatling, etc.) and tracks build performance trends over time |
| `slack` | 2.4.8 | Sends real-time build status notifications (success, failure, unstable) to configured Slack channels |

---

## 7. How These Plugins Work Together

```
  ┌─────────────────────────────────────────────────────────────────┐
  │                     Jenkins CI/CD Pipeline                      │
  │                                                                 │
  │  ┌──────────┐   ┌──────────┐   ┌──────────┐   ┌────────────┐  │
  │  │  BUILD   │──>│   TEST   │──>│ ANALYZE  │──>│  DEPLOY    │  │
  │  │          │   │          │   │          │   │            │  │
  │  │ Maven    │   │ JaCoCo   │   │ SonarQube│   │ Docker     │  │
  │  │ Docker   │   │ PIT      │   │ OWASP    │   │ Kubernetes │  │
  │  └──────────┘   └──────────┘   └──────────┘   └────────────┘  │
  │                                                                 │
  │  ┌─────────────────────────────────────────────────────────┐   │
  │  │                   MONITORING LAYER                       │   │
  │  │  Performance metrics  │  BlueOcean UI  │  Slack alerts   │   │
  │  └─────────────────────────────────────────────────────────┘   │
  └─────────────────────────────────────────────────────────────────┘
```

- **Build Stage:** Maven compiles the Java app → `docker-workflow` builds the Docker image
- **Test Stage:** `jacoco` measures code coverage → `pitmutation` verifies test strength
- **Analyze Stage:** `sonar` runs static analysis → `dependency-check` scans for CVEs
- **Deploy Stage:** `docker-workflow` pushes the image → `kubernetes-cli` deploys to the cluster
- **Monitoring:** `performance` tracks trends, `blueocean` visualizes pipelines, `slack` sends alerts

---

## 8. Identified Risks & Recommendations

| # | Risk | Severity | Recommendation |
|---|------|----------|----------------|
| 1 | Hardcoded `admin:admin` credentials in the script | 🔴 High | Use environment variables or a secrets manager (e.g., Jenkins credentials, HashiCorp Vault) |
| 2 | API token printed to stdout in cleartext | 🟠 Medium | Remove `echo` statements or redirect output to a secure log |
| 3 | Token name `demo-token66` is not unique per run | 🟡 Low | Append a timestamp or UUID to avoid token name collisions on repeat runs |
| 4 | Plugin versions are pinned and may be outdated | 🟠 Medium | Periodically review and update plugin versions; check Jenkins compatibility matrix |
| 5 | No Jenkins restart after plugin installation | 🟠 Medium | Add `curl -X POST "$JENKINS_URL/safeRestart"` at the end of the script |
| 6 | No error handling per plugin install | 🟡 Low | Add HTTP response code checks after each curl to catch individual plugin install failures |
| 7 | Cookies stored in `/tmp/cookies` (world-readable) | 🟠 Medium | Use `mktemp` for a unique file and clean up with `trap` on script exit |

---

## 9. Suggested Improved Version

```bash
#!/bin/bash
set -eo pipefail

# Use environment variables instead of hardcoded creds
JENKINS_URL="${JENKINS_URL:-http://localhost:8080}"
JENKINS_USER="${JENKINS_USER:-admin}"
JENKINS_PASS="${JENKINS_PASS:-admin}"

# Secure temp file for cookies
COOKIE_FILE=$(mktemp)
trap "rm -f $COOKIE_FILE" EXIT

# Fetch CSRF crumb (no cleartext output)
JENKINS_CRUMB=$(curl -sf --cookie-jar "$COOKIE_FILE" \
  -u "$JENKINS_USER:$JENKINS_PASS" \
  "${JENKINS_URL}/crumbIssuer/api/json" | jq .crumb -r)

# Generate unique API token
JENKINS_TOKEN=$(curl -sf -X POST \
  -H "Jenkins-Crumb:${JENKINS_CRUMB}" \
  --cookie "$COOKIE_FILE" \
  "${JENKINS_URL}/me/descriptorByName/jenkins.security.ApiTokenProperty/generateNewToken?newTokenName=token-$(date +%s)" \
  -u "$JENKINS_USER:$JENKINS_PASS" | jq .data.tokenValue -r)

# Install plugins with error checking
while read plugin; do
  echo "Installing ${plugin}..."
  HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" POST \
    --data "<jenkins><install plugin='${plugin}' /></jenkins>" \
    -H 'Content-Type: text/xml' \
    "$JENKINS_URL/pluginManager/installNecessaryPlugins" \
    --user "$JENKINS_USER:$JENKINS_TOKEN")

  if [ "$HTTP_CODE" -ne 200 ] && [ "$HTTP_CODE" -ne 302 ]; then
    echo "ERROR: Failed to install ${plugin} (HTTP $HTTP_CODE)"
  else
    echo "OK: ${plugin} installed"
  fi
done < plugins.txt

# Safe restart after install
echo "Restarting Jenkins to activate plugins..."
curl -sf -X POST "$JENKINS_URL/safeRestart" --user "$JENKINS_USER:$JENKINS_TOKEN"
```

---

## 10. Conclusion

The `installer.sh` script is a functional automation tool for bootstrapping Jenkins plugins in a dev/test environment. It correctly handles CSRF protection and API token generation. However, it has several security gaps (hardcoded credentials, cleartext token output, insecure cookie storage) that must be addressed before use in any shared or production environment. The plugin selection covers a solid CI/CD pipeline with build, test, analysis, deployment, and monitoring capabilities.

---

**Document prepared by:** DevOps Engineer
**Review status:** Ready for team review
**Next steps:** Implement suggested improvements and schedule plugin version audit