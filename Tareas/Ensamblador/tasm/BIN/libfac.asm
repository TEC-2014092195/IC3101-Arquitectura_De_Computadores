codigo segment
	public factorial
		Assume cs: codigo
		factorial proc far
			push bp
			mov bp,sp
			mov ax,[bp+6]
			cmp ax,0
			ja  L1
			mov ax,1
			jmp L2
			
		L1: dec ax
			push ax
			Call factorial
			
		ReturnF:
			mov bx,[bp+6]
			mul bx
			
		L2: pop bp
			ret 2
		factorial endP
codigo EndS
		End

