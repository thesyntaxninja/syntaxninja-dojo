#!/usr/bin/env npx tsx
/**
 * build-index.ts — Generates skills/index.json and patterns/index.json
 *
 * Scans SKILL.md and PATTERN.md files, extracts frontmatter,
 * validates CSO lint rules (strict mode), and writes index files.
 *
 * Usage:
 *   npx tsx scripts/build-index.ts
 *   # or via wrapper:
 *   bash scripts/build-index.sh
 */

import * as fs from "fs";
import * as path from "path";
import * as crypto from "crypto";

// ---------------------------------------------------------------------------
// Types
// ---------------------------------------------------------------------------

interface SkillFrontmatter {
  name: string;
  description: string;
  tags?: string[];
  triggers?: string[];
  chains_to?: string[];
  priority?: string;
  gate?: boolean;
}

interface SkillEntry {
  name: string;
  description: string;
  tags: string[];
  triggers: string[];
  chains_to: string[];
  priority: string;
  gate: boolean;
}

interface PatternFrontmatter {
  name: string;
  type?: string;
  library?: string;
  severity?: string;
  "file-globs"?: string[];
  detect?: string[];
  signatures?: string[];
  tags?: string[];
  autofix?: string;
  extends?: string;
}

interface PatternEntry {
  name: string;
  type: string;
  library: string;
  severity: string;
  detect: string[];
  signatures: string[];
  file_globs: string[];
  tags: string[];
  autofix: string;
  extends: string;
}

interface SkillIndex {
  version: string;
  hash: string;
  updated: string;
  skills: SkillEntry[];
}

interface PatternIndex {
  version: string;
  hash: string;
  updated: string;
  patterns: PatternEntry[];
}

interface LintError {
  file: string;
  field: string;
  message: string;
  severity: "error" | "warning";
}

// ---------------------------------------------------------------------------
// Frontmatter parser (simple YAML subset — no dependency needed)
// ---------------------------------------------------------------------------

function parseFrontmatter(content: string): Record<string, unknown> {
  const match = content.match(/^---\r?\n([\s\S]*?)\r?\n---/);
  if (!match) return {};

  const yaml = match[1];
  const result: Record<string, unknown> = {};

  for (const line of yaml.split("\n")) {
    const trimmed = line.trim();
    if (!trimmed || trimmed.startsWith("#")) continue;

    const colonIdx = trimmed.indexOf(":");
    if (colonIdx === -1) continue;

    const key = trimmed.slice(0, colonIdx).trim();
    let value: unknown = trimmed.slice(colonIdx + 1).trim();

    // Handle arrays: [item1, item2]
    if (typeof value === "string" && value.startsWith("[") && value.endsWith("]")) {
      const inner = value.slice(1, -1);
      value = inner
        .split(",")
        .map((s) => s.trim().replace(/^["']|["']$/g, ""))
        .filter(Boolean);
    }
    // Handle booleans
    else if (value === "true") value = true;
    else if (value === "false") value = false;
    // Handle quoted strings
    else if (typeof value === "string" && /^["'].*["']$/.test(value)) {
      value = value.slice(1, -1);
    }

    result[key] = value;
  }

  return result;
}

// ---------------------------------------------------------------------------
// CSO Lint (Strict Mode — fails hard on violations)
// ---------------------------------------------------------------------------

function lintSkill(fm: Record<string, unknown>, filePath: string): LintError[] {
  const errors: LintError[] = [];

  // REQUIRED: name
  const name = fm.name as string | undefined;
  if (!name) {
    errors.push({ file: filePath, field: "name", message: "Missing required field: name", severity: "error" });
  } else if (!/^[a-z0-9-]+$/.test(name)) {
    errors.push({
      file: filePath,
      field: "name",
      message: `Name must be lowercase letters, numbers, and hyphens only. Got: "${name}"`,
      severity: "error",
    });
  }

  // REQUIRED: description, must start with "Use when"
  const desc = fm.description as string | undefined;
  if (!desc) {
    errors.push({ file: filePath, field: "description", message: "Missing required field: description", severity: "error" });
  } else if (!desc.startsWith("Use when")) {
    errors.push({
      file: filePath,
      field: "description",
      message: `Description must start with "Use when" (CSO rule). Got: "${desc.slice(0, 60)}..."`,
      severity: "error",
    });
  }

  // REQUIRED: triggers (at least one)
  const triggers = fm.triggers as string[] | undefined;
  if (!triggers || !Array.isArray(triggers) || triggers.length === 0) {
    errors.push({
      file: filePath,
      field: "triggers",
      message: "Missing required field: triggers (must have at least one trigger)",
      severity: "error",
    });
  }

  // Frontmatter size check
  const fmStr = JSON.stringify(fm);
  if (fmStr.length > 1024) {
    errors.push({
      file: filePath,
      field: "frontmatter",
      message: `Frontmatter exceeds 1024 chars (${fmStr.length}). Keep it concise.`,
      severity: "error",
    });
  }

  return errors;
}

function lintPattern(
  fm: Record<string, unknown>,
  filePath: string,
  allPatternNames: Set<string>,
  pluginRoot: string
): LintError[] {
  const errors: LintError[] = [];

  // REQUIRED: name
  const name = fm.name as string | undefined;
  if (!name) {
    errors.push({ file: filePath, field: "name", message: "Missing required field: name", severity: "error" });
  } else if (!/^[a-z0-9-]+$/.test(name)) {
    errors.push({
      file: filePath,
      field: "name",
      message: `Name must be lowercase letters, numbers, and hyphens only. Got: "${name}"`,
      severity: "error",
    });
  }

  // REQUIRED: type
  const type = fm.type as string | undefined;
  if (!type) {
    errors.push({ file: filePath, field: "type", message: "Missing required field: type (library | structure)", severity: "error" });
  } else if (!["library", "structure"].includes(type)) {
    errors.push({
      file: filePath,
      field: "type",
      message: `Pattern type must be "library" or "structure". Got: "${type}"`,
      severity: "error",
    });
  }

  // REQUIRED: severity
  const severity = fm.severity as string | undefined;
  if (!severity) {
    errors.push({ file: filePath, field: "severity", message: "Missing required field: severity (p1 | p2 | p3)", severity: "error" });
  } else if (!["p1", "p2", "p3"].includes(severity)) {
    errors.push({
      file: filePath,
      field: "severity",
      message: `Severity must be p1, p2, or p3. Got: "${severity}"`,
      severity: "error",
    });
  }

  // Validate extends target exists
  const extendsTarget = fm.extends as string | undefined;
  if (extendsTarget) {
    // extends format: "plugin:<pattern-name>"
    const match = extendsTarget.match(/^plugin:(.+)$/);
    if (!match) {
      errors.push({
        file: filePath,
        field: "extends",
        message: `extends must use format "plugin:<pattern-name>". Got: "${extendsTarget}"`,
        severity: "error",
      });
    } else {
      const targetName = match[1];
      // Check if the target pattern exists in the plugin
      const targetPath = path.join(pluginRoot, "patterns", targetName, "PATTERN.md");
      if (!fs.existsSync(targetPath) && !allPatternNames.has(targetName)) {
        errors.push({
          file: filePath,
          field: "extends",
          message: `extends target "plugin:${targetName}" not found. Expected: patterns/${targetName}/PATTERN.md`,
          severity: "error",
        });
      }
    }
  }

  return errors;
}

// ---------------------------------------------------------------------------
// Scanner
// ---------------------------------------------------------------------------

function findFiles(dir: string, filename: string): string[] {
  const results: string[] = [];
  if (!fs.existsSync(dir)) return results;

  for (const entry of fs.readdirSync(dir, { withFileTypes: true })) {
    if (entry.name.startsWith(".")) continue;
    const fullPath = path.join(dir, entry.name);
    if (entry.isDirectory()) {
      // Skip _charter — it's the bootstrap skill, not an indexed skill
      if (entry.name === "_charter") continue;
      results.push(...findFiles(fullPath, filename));
    } else if (entry.name === filename) {
      results.push(fullPath);
    }
  }

  return results;
}

// ---------------------------------------------------------------------------
// Build
// ---------------------------------------------------------------------------

function buildSkillIndex(pluginRoot: string): { index: SkillIndex; errors: LintError[] } {
  const skillsDir = path.join(pluginRoot, "skills");
  const files = findFiles(skillsDir, "SKILL.md");
  const allErrors: LintError[] = [];
  const skills: SkillEntry[] = [];

  for (const file of files) {
    const content = fs.readFileSync(file, "utf-8");
    const fm = parseFrontmatter(content) as SkillFrontmatter & Record<string, unknown>;

    const errors = lintSkill(fm, path.relative(pluginRoot, file));
    allErrors.push(...errors);

    if (!fm.name) continue;

    skills.push({
      name: fm.name,
      description: fm.description || "",
      tags: (fm.tags as string[]) || [],
      triggers: (fm.triggers as string[]) || [],
      chains_to: (fm.chains_to as string[]) || [],
      priority: (fm.priority as string) || "normal",
      gate: fm.gate === true,
    });
  }

  // Sort: gates first, then alphabetical
  skills.sort((a, b) => {
    if (a.gate && !b.gate) return -1;
    if (!a.gate && b.gate) return 1;
    return a.name.localeCompare(b.name);
  });

  const indexContent = JSON.stringify({ skills }, null, 2);
  const hash = `sha256:${crypto.createHash("sha256").update(indexContent).digest("hex")}`;

  return {
    index: {
      version: "1.0.0",
      hash,
      updated: new Date().toISOString(),
      skills,
    },
    errors: allErrors,
  };
}

function buildPatternIndex(pluginRoot: string): { index: PatternIndex; errors: LintError[] } {
  const patternsDir = path.join(pluginRoot, "patterns");
  const files = findFiles(patternsDir, "PATTERN.md");
  const allErrors: LintError[] = [];
  const patterns: PatternEntry[] = [];

  // First pass: collect all pattern names for extends validation
  const allPatternNames = new Set<string>();
  for (const file of files) {
    const content = fs.readFileSync(file, "utf-8");
    const fm = parseFrontmatter(content);
    if (fm.name) allPatternNames.add(fm.name as string);
  }

  // Second pass: full lint + build
  for (const file of files) {
    const content = fs.readFileSync(file, "utf-8");
    const fm = parseFrontmatter(content) as PatternFrontmatter & Record<string, unknown>;

    const errors = lintPattern(fm, path.relative(pluginRoot, file), allPatternNames, pluginRoot);
    allErrors.push(...errors);

    if (!fm.name) continue;

    patterns.push({
      name: fm.name,
      type: (fm.type as string) || "library",
      library: (fm.library as string) || "",
      severity: (fm.severity as string) || "p2",
      detect: (fm.detect as string[]) || [],
      signatures: (fm.signatures as string[]) || [],
      file_globs: (fm["file-globs"] as string[]) || [],
      tags: (fm.tags as string[]) || [],
      autofix: (fm.autofix as string) || "",
      extends: (fm.extends as string) || "",
    });
  }

  patterns.sort((a, b) => a.name.localeCompare(b.name));

  const indexContent = JSON.stringify({ patterns }, null, 2);
  const hash = `sha256:${crypto.createHash("sha256").update(indexContent).digest("hex")}`;

  return {
    index: {
      version: "1.0.0",
      hash,
      updated: new Date().toISOString(),
      patterns,
    },
    errors: allErrors,
  };
}

// ---------------------------------------------------------------------------
// Main
// ---------------------------------------------------------------------------

function main() {
  const pluginRoot = path.resolve(__dirname, "..");

  console.log("SyntaxNinja Dojo — Building indexes...\n");

  // Build skill index
  const { index: skillIndex, errors: skillErrors } = buildSkillIndex(pluginRoot);
  const skillOutPath = path.join(pluginRoot, "skills", "index.json");
  fs.writeFileSync(skillOutPath, JSON.stringify(skillIndex, null, 2) + "\n");
  console.log(`  skills/index.json — ${skillIndex.skills.length} skills indexed`);

  // Build pattern index
  const { index: patternIndex, errors: patternErrors } = buildPatternIndex(pluginRoot);
  const patternOutPath = path.join(pluginRoot, "patterns", "index.json");
  fs.writeFileSync(patternOutPath, JSON.stringify(patternIndex, null, 2) + "\n");
  console.log(`  patterns/index.json — ${patternIndex.patterns.length} patterns indexed`);

  // Report errors — strict mode: any error is a hard failure
  const allErrors = [...skillErrors, ...patternErrors];
  const hardErrors = allErrors.filter((e) => e.severity === "error");
  const warnings = allErrors.filter((e) => e.severity === "warning");

  if (warnings.length > 0) {
    console.log(`\n  Warnings (${warnings.length}):\n`);
    for (const err of warnings) {
      console.log(`    ⚠ ${err.file} [${err.field}]: ${err.message}`);
    }
  }

  if (hardErrors.length > 0) {
    console.log(`\n  ERRORS (${hardErrors.length}) — index is invalid:\n`);
    for (const err of hardErrors) {
      console.log(`    ✗ ${err.file} [${err.field}]: ${err.message}`);
    }
    console.log("\n  Fix all errors before publishing. The index is the single source of truth.\n");
    process.exit(1);
  }

  console.log("\n  Done. No errors.\n");
}

main();
