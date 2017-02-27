cseg        segment  para public 'CODE'
            assume   cs:cseg,ds:cseg,es:cseg
            org      100h
pp          proc     near

            mov      di,offset pantalla
            mov      si,0
            mov      ax,0b800h
            mov      ds,ax
            mov      cx,4000
            rep      movsb

            mov      ah,6
            mov      al,0
            mov      cx,0
            mov      dh,24
            mov      dl,79
            mov      bh,60h
            int      10h

            push     cs
            pop      ds
            mov      dx,offset msg
            mov      ah,9
            int      21h

            mov      ah,0
            int      16h

            mov      ax,0b800h
            mov      es,ax
            mov      di,0
            mov      si,offset pantalla
            mov      cx,4000
            rep      movsb
            int      20h
msg         db       'Este mensaje dice que esta diciendo $'
pantalla    db       0
pp          endp
cseg        ends
            end      pp

