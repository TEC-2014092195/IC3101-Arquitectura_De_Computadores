
      

CodigoP1 Segment PARA 'Code'

	Public GuardarPila
	Assume CS:CodigoP1
	
	
	GuardarPila Proc Far
		;nesecita tener cargado el en el DI la ultima poscicion del PSP
		Mov Bx, 2 ; posicion de donde va a iniciar a guardar a partir del 
		Xor Cx, Cx ; para limpiar el registro
		Xor Dx, Dx ;limpia el registro
		
		Mov Cl, Byte PTR[Bx+7Eh] ;Pone la cantidad que se va aguardar 
		Dec Cx
	GuardarAPila:
		mov Dl, Byte PTR [Bx+80h]
		push Byte PTR Dx
		Inc Bx
		loop GuardarAPila
		
		ret
	GuardarPila EndP

CodigoP1 EndS