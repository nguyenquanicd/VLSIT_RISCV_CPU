"""Render an overview SVG directly from the generated draw.io library cells.

Usage: python scripts/render_cluster_preview.py
Input: figures/cluster_architecture/vlsit_rtl_hierarchy.drawio.
Output: cluster_architecture.svg and preview.html in the same directory.
Native description tables remain in draw.io; the document image crops to the
topology. Only library entries 0, 1, 5, 32 are supported. Unknown shapes fail.
Exit: 0 success, 1 input/render error. Standard library only; no network.
"""
from pathlib import Path
import html
import re
import textwrap
import xml.etree.ElementTree as ET

ROOT=Path(__file__).resolve().parents[1]
OUT=ROOT / 'project_support/architecture_figures/cluster_architecture'


def plain(value):
    value=re.sub(r'<br\s*/?>','\n',value,flags=re.I)
    return html.unescape(re.sub(r'<[^>]*>','',value))


def main():
    model=ET.parse(OUT/'vlsit_rtl_hierarchy.drawio').find('.//mxGraphModel')
    shapes=[]; labels=[]; pads=[]; edges=[]; extents=[]
    for c in model.findall('./root/mxCell'):
        if c.get('vlsit_native_table') or c.get('parent')!='1':continue
        g=c.find('mxGeometry')
        if g is None:continue
        ent=c.get('vlsit_library_entry')
        if ent not in ('0','1','5','32'):raise ValueError('Unsupported source template '+str(ent))
        if ent=='1':
            sp=g.find("mxPoint[@as='sourcePoint']"); tp=g.find("mxPoint[@as='targetPoint']")
            if sp is None or tp is None:continue
            pts=[(float(sp.get('x')),float(sp.get('y')))]
            pts += [(float(p.get('x')),float(p.get('y'))) for p in g.findall('./Array/mxPoint')]
            pts += [(float(tp.get('x')),float(tp.get('y')))]
            if c.get('id','').startswith('i'):
                edges.append(pts)
            continue
        x,y,w,h=(float(g.get(k,0)) for k in ('x','y','width','height'))
        # Tables and their following legend lie below the topology.
        table_y=min(float(z.find('mxGeometry').get('y')) for z in model.findall('./root/mxCell')
                    if z.get('vlsit_native_table') and z.get('parent')=='1')
        if y>=table_y:continue
        item=(x,y,w,h,c.get('value',''),c.get('style',''))
        {'0':labels,'5':pads,'32':shapes}[ent].append(item)
        extents.append((x,y,x+w,y+h))
    bottom=max(y2 for x,y,x2,y2 in extents)+30
    right=max(x2 for x,y,x2,y2 in extents)+30
    left=max(0,min(x for x,y,x2,y2 in extents)-30)
    top=max(0,min(y for x,y,x2,y2 in extents)-30)
    svg=[f'<svg xmlns="http://www.w3.org/2000/svg" width="{right-left:g}" height="{bottom-top:g}" viewBox="{left:g} {top:g} {right-left:g} {bottom-top:g}">',
         '<rect x="0" y="0" width="100%" height="100%" fill="white"/>',
         '<defs><marker id="arrow" viewBox="0 0 10 10" refX="9" refY="5" markerWidth="7" markerHeight="7" orient="auto"><path d="M 0 0 L 10 5 L 0 10 Z" fill="black"/></marker></defs>']
    for x,y,w,h,value,style in shapes:
        dash=' stroke-dasharray="6 4"' if 'dashed=1' in style else ''
        svg.append(f'<rect x="{x:g}" y="{y:g}" width="{w:g}" height="{h:g}" fill="white" stroke="black" stroke-width="2"{dash}/>')
    previous=[]
    for pts in edges:
        # Exclude the description-table legend, which is outside the crop.
        if any(y>=bottom for x,y in pts):continue
        commands=[f'M {pts[0][0]:g} {pts[0][1]:g}']
        for (x1,y1),(x2,y2) in zip(pts,pts[1:]):
            hits=[]
            for old in previous:
                for (a,b),(c,d) in zip(old,old[1:]):
                    if y1==y2 and a==c and min(x1,x2)<a<max(x1,x2) and min(b,d)<y1<max(b,d):hits.append((a,y1))
                    if x1==x2 and b==d and min(y1,y2)<b<max(y1,y2) and min(a,c)<x1<max(a,c):hits.append((x1,b))
            hits=sorted(set(hits),key=lambda p:abs(p[0]-x1)+abs(p[1]-y1))
            for hx,hy in hits:
                if y1==y2:
                    sign=1 if x2>x1 else -1
                    commands += [f'L {hx-6*sign:g} {hy:g}',f'Q {hx:g} {hy-12:g} {hx+6*sign:g} {hy:g}']
                else:
                    sign=1 if y2>y1 else -1
                    commands += [f'L {hx:g} {hy-6*sign:g}',f'Q {hx+12:g} {hy:g} {hx:g} {hy+6*sign:g}']
            commands.append(f'L {x2:g} {y2:g}')
        path=' '.join(commands)
        svg += [f'<path d="{path}" fill="none" stroke="white" stroke-width="5"/>',
                f'<path d="{path}" fill="none" stroke="black" stroke-width="2" marker-end="url(#arrow)"/>']
        previous.append(pts)
    for x,y,w,h,value,style in pads:
        svg.append(f'<path d="M{x:g},{y:g} h{w:g} v{h:g} h{-w:g} Z M{x:g},{y:g} l{w:g},{h:g} M{x+w:g},{y:g} l{-w:g},{h:g}" fill="white" stroke="black" stroke-width="2"/>')
    for x,y,w,h,value,style in shapes+labels:
        lines=plain(value).split('\n')
        if not any(lines):continue
        wrapped=[]
        for line in lines:
            wrapped += textwrap.wrap(line,width=max(1,int((w-8)/9.2)),break_long_words=False) or ['']
        align='start' if 'align=left' in style else 'end' if 'align=right' in style else 'middle'
        tx=x+4 if align=='start' else x+w-4 if align=='end' else x+w/2
        ty=y+h/2-(len(wrapped)-1)*11+6
        svg.append(f'<text x="{tx:g}" y="{ty:g}" text-anchor="{align}" font-family="Arial,Helvetica,sans-serif" font-size="18" fill="black">')
        for n,line in enumerate(wrapped):svg.append(f'<tspan x="{tx:g}" dy="{0 if n==0 else 22}">{html.escape(line)}</tspan>')
        svg.append('</text>')
    svg.append('</svg>')
    (OUT/'cluster_architecture.svg').write_text('\n'.join(svg),encoding='utf-8')
    (OUT/'preview.html').write_text('<!doctype html><html><meta charset="utf-8"><style>html,body{margin:0;background:white}img{display:block;width:100vw;height:auto}</style><img src="cluster_architecture.svg" alt="Document-grounded cluster architecture">',encoding='utf-8')
    print('Rendered topology from draw.io source:',OUT/'cluster_architecture.svg')


if __name__=='__main__':main()
