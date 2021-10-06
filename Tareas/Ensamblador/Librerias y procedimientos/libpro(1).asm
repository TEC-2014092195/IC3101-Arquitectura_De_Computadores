Codigo Segment
	public delay1,delay2
	
		Assume cs:codigo

Delay1 proc Far
	eti:
		loop eti
		ret
Delay1 endP

Delay2 proc Far ;como estan en otro segmento de codigo tiene que ser Far
		mov bp,sp
		mov cx,2*2[bp] 
	eti1:
		loop eti1
		ret 2		;hace pop cx
Delay2 endP

Codigo EndS
	End