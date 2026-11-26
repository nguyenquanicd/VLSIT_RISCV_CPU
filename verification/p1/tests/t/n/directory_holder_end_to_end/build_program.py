"""DEC-013/A-04: independently encoded RV64 programs and data oracles."""
from pathlib import Path
HERE=Path(__file__).resolve().parent

def generate():
 code={};listing=[];checks=[]
 pos=0
 def at(pc):
  nonlocal pos;pos=pc
 def emit(w,desc):
  nonlocal pos
  pc=pos;code[pc]=w;listing.append(f'{0x80000000+pc:08x}: {w:08x} {desc}');pos+=4;return pc
 def addi(rd,rs,n):return emit(((n&4095)<<20)|(rs<<15)|(rd<<7)|0x13,'addi')
 def address(rd,n):
  emit(((n+0x800)&0xfffff000)|(rd<<7)|0x37,'lui address');addi(rd,rd,((n&4095)^2048)-2048)
  emit((32<<20)|(rd<<15)|(1<<12)|(rd<<7)|0x13,'slli32');emit((32<<20)|(rd<<15)|(5<<12)|(rd<<7)|0x13,'srli32')
 def add(rd,a,b):emit((b<<20)|(a<<15)|(rd<<7)|0x33,'add')
 def ld(rd,rs,off=0):return emit((off<<20)|(rs<<15)|(3<<12)|(rd<<7)|3,'ld')
 def sd(rs,base,off=0):return emit(((off>>5)<<25)|(rs<<20)|(base<<15)|(3<<12)|((off&31)<<7)|0x23,'sd')
 def branch(rs1,rs2,target,fn=0):
  d=target-pos;return emit((((d>>12)&1)<<31)|(((d>>5)&63)<<25)|(rs2<<20)|(rs1<<15)|(fn<<12)|(((d>>1)&15)<<8)|(((d>>11)&1)<<7)|0x63,'branch')
 def jump(target):
  d=target-pos;return emit((((d>>20)&1)<<31)|(((d>>1)&1023)<<21)|(((d>>11)&1)<<20)|(((d>>12)&255)<<12)|0x6f,'jal')
 def zero_dependency():emit((32<<25)|(13<<20)|(15<<15)|(22<<7)|0x33,'sub last-word minus expected');add(11,11,22)
 # Common software knows its hart id and the SoC-provided active-hart count word.
 address(5,0x80000a00);emit((0x305<<20)|(5<<15)|(1<<12)|0x73,'csrw mtvec')
 emit((0xf14<<20)|(2<<12)|(10<<7)|0x73,'csrr mhartid')
 address(12,0x80000c00);address(20,0x80000d00)
 emit((4<<20)|(10<<15)|(1<<12)|(18<<7)|0x13,'slli hart,4');add(20,20,18)
 emit((1<<12)|(19<<7)|0x37,'lui stride 4096')
 address(11,0x80001000)
 branch(10,0,0x500,1);jump(0x100)
 at(0x100);fault_pc=pos;store_pcs=[]
 for i in range(9):
  addi(13,0,256+i);store_pcs.append(sd(13,11))
  addi(13,0,512+i);store_pcs.append(sd(13,11,8))
  checks.append((ld(14,11),256+i));checks.append((ld(15,11,8),512+i))
  zero_dependency();add(11,11,19)
 addi(13,0,1);sd(13,12);jump(0x800)
 at(0x500);poll=pos;ld(14,12);branch(14,0,poll)
 address(11,0x80001000)
 for i in range(9):
  addi(13,0,512+i)
  checks.append((ld(14,11),256+i));checks.append((ld(15,11,8),512+i))
  zero_dependency();add(11,11,19)
 address(11,0x80001000);addi(13,0,1)
 amo_pc=emit((3<<25)|(13<<20)|(11<<15)|(3<<12)|(14<<7)|0x2f,'amoadd.d.aqrl')
 addi(13,0,1);sd(13,20);jump(0xb00)
 at(0x800);address(18,0x80000e00);ld(17,18);addi(17,17,-1);address(21,0x80000d10)
 wait_pc=pos;ld(14,21);branch(14,0,wait_pc);addi(21,21,16);addi(17,17,-1);branch(17,0,wait_pc,1)
 address(11,0x80001000)
 for i in range(9):
  p=ld(14,11);checks.append((p,"64'd256+64'(HARTS)-64'd1" if i==0 else 256+i))
  checks.append((ld(15,11,8),512+i));add(11,11,19)
 address(11,0x80001000)
 emit((1<<20)|(11<<15)|(2<<12)|0xf,'cbo.clean final shared counter')
 jump(0xb00)
 at(0xa00);addi(13,0,1);sd(13,12);jump(0x800)
 at(0xb00);done_pc=pos;jump(pos)
 assert max(code)<0xc00
 (HERE/'program_listing.txt').write_text('\n'.join(listing)+'\n')
 for case in ('dirty_eviction','clean_eviction','amo_refill_error','lr_refill_error'):
  image=dict(code)
  if case=='clean_eviction':
   for p in store_pcs:image[p]=0x13
  if 'refill_error' in case:
   # Ownership is granted first; a native RRESP fault leaves a phantom holder.
   image[fault_pc]=(3<<25)|(11<<15)|(3<<12)|(14<<7)|0x2f if case.startswith('amo') else (2<<27)|(3<<25)|(11<<15)|(3<<12)|(14<<7)|0x2f
   d=0;image[fault_pc+4]=0x6f
  readable=[]
  descriptions={int(line[:8],16)-0x80000000:line.split(' ',2)[2] for line in listing}
  for pc,w in sorted(image.items()):
   desc=descriptions[pc]
   if case=='clean_eviction' and pc in store_pcs:desc='nop; read-only fill'
   if 'refill_error' in case and pc==fault_pc:desc='amoadd.d.aqrl x14,x0,(x11)' if case.startswith('amo') else 'lr.d.aqrl x14,(x11)'
   if 'refill_error' in case and pc==fault_pc+4:desc='j self; must trap before reaching this fallback'
   readable.append(f'{0x80000000+pc:08x}: {w:08x} {desc}')
  (HERE/(case+'.lst')).write_text('# Actual encoded image listing; not assembler input.\n'+'\n'.join(readable)+'\n')
  words=[0]*8192
  for pc,w in image.items():words[pc//8]|=w<<(32*((pc//4)%2))
  for i in range(9):
   words[(0x1000+i*4096)//8]=(0xd00+i) if case=='dirty_eviction' else 256+i
   words[(0x1000+i*4096+8)//8]=(0xe00+i) if case=='dirty_eviction' else 512+i
  (HERE/(case+'.hex')).write_text(''.join(f'{w:016x}\n' for w in words))
 (HERE/'program_constants.svh').write_text(f"localparam logic [63:0] FAULT_PC=64'h{0x80000000+fault_pc:x}, AMO_PC=64'h{0x80000000+amo_pc:x}, DONE_PC=64'h{0x80000000+done_pc:x};\n")
 (HERE/'program_checks.svh').write_text(''.join(f"64'h{0x80000000+pc:x}: begin check_valid=1; expected=64'({v}); end\n" for pc,v in checks))
if __name__=='__main__':generate()
