"""Extract event-sampled WF-019 evidence from actual simulator VCD, without inventing cycles."""
from pathlib import Path
import json,re,shutil,subprocess,sys
ROOT=Path(__file__).resolve().parents[3]
SOURCE=ROOT/'rtl/reports/fence_i_end_to_end'
OUT=Path(__file__).with_name('waveforms_sim')
RENDER=Path('C:/Users/PC/.codex/skills/vlsit-asic-ip-microspec/scripts/vlsit_waveform_svg.py')

def read_vcd(path):
    frames=[]; state={}; stamp=None
    for line in path.read_text().splitlines():
        if line.startswith('#'):
            if stamp is not None: frames.append((stamp,state.copy()))
            stamp=int(line[1:])
        elif stamp is not None and line:
            if line[0] in '01xz': state[line[1:]]=line[0]
            elif line.startswith('b'):
                value,key=line[1:].split();state[key]=value
    if stamp is not None: frames.append((stamp,state.copy()))
    return frames

def main():
    OUT.mkdir(exist_ok=True)
    rows=['# WF-019 simulation comparison / Đối chiếu waveform WF-019','',
          'EN: SVG columns are actual event samples with nanosecond labels; gaps are nonuniform. The VCD retains every sampled rising edge. MATCH means DEC-030/031 ordering and architectural checks passed; it is not a fixed-latency claim.',
          '', 'VI: Mỗi cột SVG là mẫu sự kiện thật, có nhãn ns; khoảng cách thời gian không đều. VCD giữ mọi cạnh clock đã lấy mẫu. MATCH xác nhận thứ tự DEC-030/031 và kiểm tra kiến trúc, không khẳng định latency cố định.',
          '', '| Test | Result | Cycles | Artifacts |','|---|---|---:|---|']
    results=[]
    for h in (2,4):
      for sup in (False,True):
       for err in (0,1):
        suffix='_supervisor' if sup else ''
        key=f'{h}h_error{err}{suffix}'
        log=SOURCE/f'simulation_{key}.log'
        text=log.read_text()
        assert 'PASS: real CVA6 FENCE.I' in text and 'assertion failures: 0, assertions never exercised: 0' in text,log
        cycles=int(re.search(r'cycles=(\d+)',text).group(1))
        stem=f'WF-019_{key}'
        shutil.copyfile(SOURCE/f'service_{key}.vcd',OUT/f'{stem}.vcd')
        frames=read_vcd(OUT/f'{stem}.vcd');pick=set()
        prev={}
        for i,(time,s) in enumerate(frames):
            # Hart-0 service events plus trap/invalidation. Retain neighbors.
            service=(int(s.get('o','0'),2)==0 and any(s.get(k)=='1' and prev.get(k)!='1' for k in ('a','c','i','l','m')))
            arch=any(s.get(k)!=prev.get(k) for k in ('f0','t0','x0'))
            if service or arch:
                pick.update(range(max(0,i-1),min(len(frames),i+2)))
            prev=s
        chosen=[frames[i] for i in sorted(pick)]
        signals=[]
        for name,k in [('FENCE pending','f0'),('CCU begin','a'),('PREPARE valid','c'),('finish valid','i'),('COMMIT (0=ABORT)','k'),('terminal ACK','l'),('service done','m'),('service error','n'),('trap valid','t0'),('I-cache invalidate','x0')]:
            values=[s.get(k,'0') for _,s in chosen]
            wave=''.join(v if i==0 or v!=values[i-1] else '.' for i,v in enumerate(values))
            signals.append({'name':name,'wave':wave})
        signals.append({'name':'trap cause','wave':'='*len(chosen),'data':[str(int(s.get('c0','0'),2)) for _,s in chosen]})
        signals.append({'name':'sample time (ns)','wave':'='*len(chosen),'data':[str(t) for t,_ in chosen]})
        spec={'signal':signals,'head':{'text':f'WF-019 {key}: actual event samples, nonuniform time'},'config':{'hscale':1}}
        jp=OUT/f'{stem}.json';jp.write_text(json.dumps(spec,indent=2))
        subprocess.run([sys.executable,str(RENDER),'render',str(jp),'--out',str(OUT/f'{stem}.svg'),'--cell','32','--force'],check=True,stdout=subprocess.DEVNULL)
        rows.append(f'| {key} | MATCH | {cycles} | [VCD]({stem}.vcd), [WaveJSON]({stem}.json), [SVG]({stem}.svg) |')
        results.append({'harts':h,'supervisor':sup,'error':err,'cycles':cycles,'pass':True})
    rows+=['','Other HDS waveform IDs are outside this focused change and are not revalidated by these tests. / Các waveform ID khác trong HDS không được kiểm chứng lại bởi bộ test riêng này.']
    (OUT/'waveform_compare.md').write_text('\n'.join(rows)+'\n',encoding='utf-8')
    (SOURCE/'results.json').write_text(json.dumps(results,indent=2))
    print('PASS: eight real-instruction tests, VCD/JSON/SVG evidence and assertion activation verified')
if __name__=='__main__': main()
