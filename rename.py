#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""rename.yml 에 적은 대로 모델 이름을 프로젝트 전체에서 일괄 변경한다."""
import os, re, sys, json, shutil

ROOT = os.path.dirname(os.path.abspath(__file__))
HIST = os.path.join(ROOT, ".rename_history.json")


def load_renames():
    """의존성 없이 rename.yml 의 단순 key: value 만 읽는다."""
    path = os.path.join(ROOT, "rename.yml")
    pairs, in_block = {}, False
    for raw in open(path, encoding="utf-8"):
        line = raw.rstrip("\n")
        if line.strip().startswith("#") or not line.strip():
            continue
        if line.strip() == "renames:":
            in_block = True
            continue
        if in_block and line.startswith(("  ", "\t")) and ":" in line:
            k, _, v = line.strip().partition(":")
            k, v = k.strip(), v.strip().strip("'\"")
            if v and v != k:
                pairs[k] = v
    return pairs


def walk_files():
    for base, dirs, files in os.walk(ROOT):
        dirs[:] = [d for d in dirs if d not in
                   ("target", "dbt_packages", "logs", ".git", "__pycache__")]
        for f in files:
            if f.endswith((".sql", ".yml", ".yaml", ".md")):
                yield os.path.join(base, f)


def apply(pairs):
    if not pairs:
        print("변경할 항목이 없습니다. rename.yml 의 오른쪽을 채우세요.")
        return

    # 1) 파일 내용 치환
    touched = 0
    for path in walk_files():
        text = orig = open(path, encoding="utf-8").read()
        for old, new in pairs.items():
            text = re.sub(r"(ref\(\s*['\"])%s(['\"]\s*\))" % re.escape(old),
                          r"\g<1>%s\g<2>" % new, text)
            text = re.sub(r"(^\s*-\s*name:\s*)%s\s*$" % re.escape(old),
                          r"\g<1>%s" % new, text, flags=re.M)
            text = re.sub(r"(compare_model:\s*ref\(\s*['\"])%s(['\"])" % re.escape(old),
                          r"\g<1>%s\g<2>" % new, text)
        if text != orig:
            open(path, "w", encoding="utf-8").write(text)
            touched += 1

    # 2) 파일명 변경
    renamed = []
    for base, dirs, files in os.walk(os.path.join(ROOT, "models")):
        for f in files:
            if not f.endswith(".sql"):
                continue
            stem = f[:-4]
            if stem in pairs:
                src = os.path.join(base, f)
                dst = os.path.join(base, pairs[stem] + ".sql")
                shutil.move(src, dst)
                renamed.append((stem, pairs[stem]))

    json.dump(pairs, open(HIST, "w"), ensure_ascii=False, indent=1)
    print(f"파일 {touched}개 내용 수정, 모델 {len(renamed)}개 이름 변경")
    for a, b in renamed:
        print(f"  {a}  →  {b}")
    print("\n확인: dbt parse && dbt ls")


def undo():
    if not os.path.exists(HIST):
        print("되돌릴 이력이 없습니다.")
        return
    prev = json.load(open(HIST))
    apply({v: k for k, v in prev.items()})
    os.remove(HIST)


if __name__ == "__main__":
    (undo if "--undo" in sys.argv else lambda: apply(load_renames()))()
