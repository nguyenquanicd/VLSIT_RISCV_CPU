"""TEST-050: eight dirty conflict lines, then a ninth load, RV64 encoder."""
from pathlib import Path
HERE=Path(__file__).resolve().parent

def generate():
 code=[];listing=[];checks=[]
 def emit(w,desc):
  pc=0x80000000+4*len(code);code.append(w);listing.append(f'{pc:08x}: {w:08x} {desc}');return pc
 def addi(rd,rs,n):return emit(((n&4095)<<20)|(rs<<15)|(rd<<7)|0x13,f'addi x{rd},x{rs},{n}')
 def address(rd,n):
  emit(((n+0x800)&0xfffff000)|(rd<<7)|0x37,'lui address')
  addi(rd,rd,((n&4095)^2048)-2048)
  emit((32<<20)|(rd<<15)|(1<<12)|(rd<<7)|0x13,'slli 32')
  emit((32<<20)|(rd<<15)|(5<<12)|(rd<<7)|0x13,'srli 32')
 def add(rd,a,b):emit((b<<20)|(a<<15)|(rd<<7)|0x33,'add')
 def store(rs,off):emit(((off>>5)<<25)|(rs<<20)|(11<<15)|(3<<12)|((off&31)<<7)|0x23,'sd')
 def load(rd,off,base):return emit((off<<20)|(base<<15)|(3<<12)|(rd<<7)|3,'ld')
 emit((0xf14<<20)|(2<<12)|(10<<7)|0x73,'csrr mhartid')
 emit((4<<20)|(10<<15)|(1<<12)|(18<<7)|0x13,'slli hart,4')
 address(11,0x80000200);add(11,11,18)
 emit((1<<12)|(19<<7)|0x37,'lui stride 4096')
 address(21,0x80009300);add(21,21,18)
 for i in range(8):
  addi(13,18,0x100+i);store(13,0)
  addi(13,18,0x200+i);store(13,8)
  p=load(14,0,11);checks.append((p,0x100+i))
  p=load(14,8,11);checks.append((p,0x200+i))
  emit((32<<25)|(13<<20)|(14<<15)|(22<<7)|0x33,'sub dependency, last load minus expected')
  add(11,11,22)
  add(11,11,19)
 older_pc=load(15,0,21)
 target_pc=load(14,0,11)
 done=emit(0x0000006f,'j done')
 words=[0]*8192
 for i,w in enumerate(code):words[i//2]|=w<<(32*(i%2))
 for h in range(4):
  words[(0x8200+h*16)//8]=0x999+h
  words[(0x9300+h*16)//8]=0x55+h
 (HERE/'program.hex').write_text(''.join(f'{w:016x}\n' for w in words))
 (HERE/'program_listing.txt').write_text('\n'.join(listing)+'\n')
 (HERE/'program_constants.svh').write_text(f"localparam logic [63:0] EVICT_PC=64'h{target_pc:x}, DONE_PC=64'h{done:x}, OLDER_PC=64'h{older_pc:x};\n")
 (HERE/'program_checks.svh').write_text(''.join(f"64'h{pc:x}: begin check_valid=1; expected=64'd{v}+64'(h*16); end\n" for pc,v in checks))
if __name__=='__main__':generate()
