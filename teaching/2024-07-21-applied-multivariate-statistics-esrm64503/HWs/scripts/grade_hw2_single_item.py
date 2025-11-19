import csv, re, math
from pathlib import Path

KEY_FILE = 'HW2_Keys_Response_2025'
ANS_FILE = 'hw2_answers.csv'
OUT_FILE = 'hw2_scores.txt'

num_re = re.compile(r"[-+]?\d*\.?\d+(?:[eE][-+]?\d+)?")

def norm_token(tok: str) -> str:
    t = tok.strip().lower()
    t = (t.replace('<0.001','0.000')
           .replace('p<0.000','0.000')
           .replace('p.value','').replace('pvalue','').replace('p-value','').replace('p value','')
           .replace('correlation:','').replace('se:','')
           .replace('chisq-diff:','').replace('chi-square difference','')
           .replace('aic','').replace('bic','')
           .replace(':',' ').replace('=',' '))
    t = ' '.join(t.split())
    m = num_re.search(t)
    if m:
        return m.group(0)
    if t in ('na','nan'):
        return 'na'
    return t

def eq_num(a: str, b: str, rel=5e-3, abs_=5e-3) -> bool:
    try:
        fa = float(a); fb = float(b)
        return math.isclose(fa, fb, rel_tol=rel, abs_tol=abs_)
    except Exception:
        return a == b

def parse_key() -> dict:
    txt = Path(KEY_FILE).read_text().strip()
    lines = [l.strip() for l in txt.splitlines() if l.strip() and not l.startswith('##')]
    vals = []
    for l in lines:
        vals.append([p.strip() for p in l.split('/')])
    canon = {}
    # Q1-3
    for i in range(3):
        canon[f'Q{i+1}'] = [norm_token(x) for x in vals[i]]
    # Q4-6
    for i in range(3,6):
        canon[f'Q{i+1}'] = [norm_token(x) for x in vals[i]]
    # Q7-8 pairs
    canon['Q7'] = [norm_token(x) for x in vals[6]]
    canon['Q8'] = [norm_token(x) for x in vals[7]]
    # Q9
    canon['Q9'] = [norm_token(x) for x in vals[8]]
    return canon

def check_item(answer: str, expect_parts: list[str]) -> bool:
    # Extract tokens from answer; accept commas, slashes, spaces
    toks = [norm_token(t) for t in re.split(r"[,/ ]+", answer)]
    nums = [t for t in toks if t and (t=='na' or num_re.fullmatch(t))]
    # Need at least len(expect_parts) tokens
    if len(nums) < len(expect_parts):
        return False
    # Compare first k tokens to expected with tolerance
    for a,e in zip(nums, expect_parts):
        if e == 'na':
            if a != 'na':
                return False
        else:
            if not eq_num(a, e):
                return False
    return True

def main():
    canon = parse_key()
    rows = list(csv.DictReader(open(ANS_FILE, newline='')))
    out_lines = []
    for r in rows:
        name = r['Name'].strip()
        item_scores = []
        correct = 0
        for i in range(1,10):
            q = f'Q{i}'
            ok = check_item(r[q], canon[q])
            item_scores.append((q, 1 if ok else 0))
            correct += 1 if ok else 0
        out_lines.append((name, correct, 9, item_scores))

    with open(OUT_FILE, 'w') as f:
        for name, sc, tot, details in out_lines:
            f.write(f"{name}: {sc}/{tot}\n")
            f.write(' ' + ' '.join([f"{q}={s}/1" for q,s in details]) + '\n')

if __name__ == '__main__':
    main()

