.data
init: .asciiz "init.txt"
rotors: .asciiz "rotors.txt"
plaintext: .asciiz "plaintext.txt"
ciphertext: .asciiz "ciphertext.txt"
tablica0: .space 20 #da ustawienia bebnow
tablicapom: .space 2000 #tablica pomocnicza
tablicapomoc: .space 1024
tablica2: .space 2000
tablica3: .space 400
tablica4: .space 1024
.text

main:
	
read_init:
li $v0, 13 #otwieram plik
	la $a0, init
	li $a1, 0 #do odczytu
	li $a2, 0 #ignorowany
	syscall
	move $s0, $v0 #zapamietaj deskryptor pliku
	
	li $v0, 14 #system call for file_read
	move $a0, $s0
	la $a1, tablica0 #bedziemy czytac do bufora
	li $a2,14 #ilosc bajtow
	syscall
	
	jal zmien_liczbe
	
	powrot:
	la $t3,0
	lb $t1,tablicapom($t3)
	
	move $s1, $t1
	addu $t3, $t3, 1
	lb $t1,tablicapom($t3)
	move $s2, $t1
	addu $t3, $t3, 1
	lb $t1,tablicapom($t3)
	move $s3, $t1
	addu $t3, $t3, 1
	
	
	li $v0, 16 #zamykanie pliku
	move $a0, $s0
	syscall
	
	b read_rotors
	#debug
	la $a0, ($s1)
	li $v0, 1
	syscall
	
	la $a0, ($s2)
	li $v0, 1
	syscall
	
	la $a0, ($s3)
	li $v0, 1
	syscall
	
	
read_rotors: #przepisz same cyfry z pliku rotors.txt do bufora buf_rot
	
	li $v0, 13 #otwieram plik
	la $a0, rotors
	li $a1, 0 #do odczytu
	li $a2, 0 #ignorowany
	syscall
	move $s0, $v0 #zapamietaj deskryptor pliku
	
rotory_zapisz:

la $t3, 0
la $t0, 0
la $t2, 0

	li $v0, 14  #czytaj z pliku
	move $a0, $s0 #rotors.txt
	la $a1, tablicapom #bedziemy czytac do bufora
	li $a2, 2000 #jedna litere
	syscall
		#blt $v0, 1, zamknij_rotors #koniec pliku
		
		rotory_zapisz1:
		lb $t1,tablicapom($t3) #laduj litere
		beqz $t1, zamknij_rotors
		addu $t3, $t3, 1
		blt $t1, 48, rotory_zapisz1#czy na pewno cyfra
		bgt $t1, 57, rotory_zapisz1
	
		#bgeu $t0, 112, zapisz_drugatab
		sb $t1,tablica2($t0)    #jesli cyfra to do bufora
		addu $t0, $t0, 1 #przesuwam wskaznik bufora
		
		b rotory_zapisz1 #loop

zamknij_rotors:
	li $v0, 16 #zamykanie pliku
	move $a0, $s0
	syscall
#nachinaetsa hujnia s ciagami	
la $t0, 0
la $t3, 0
	zapisz_ciag:
	add $t0, $t0, 2
	lb $t1,tablica2($t0) 
	beqz $t1, puste_miejsce
	jal zmien_na_liczbe
	bgeu $t3, 104, zapisz_drugatab
	sb $t1,tablica2($t3)
	
	add $t0, $t0, 1
	add $t3, $t3, 1
	j zapisz_ciag
		
	
puste_miejsce:
	la $t1, 0
	sb $t1,tablica2($t3)
	add $t3, $t3, 1	
	lb $t1,tablica2($t3) 
	beqz $t1, otworz_plik
	j puste_miejsce
	
otworz_plik:

	li $v0, 13 #otwieranie pliku			
	la $a0, plaintext
	li $a1, 0 #do odczytu
	li $a2, 0 #ignore
	syscall
	la $s0, 0
	move $s0, $v0
	

	 
zapisz_wiersz:
	la $s7, tablica4
	la $s6, tablicapomoc
	move $t4, $s1
	la $t5, 0
	la $t6, 0
	zapisz_wiersz1:
	
	li $v0, 14 #system call for file_read
	move $a0, $s0
	move $a1, $s6 #bedziemy czytac do bufora
	li $a2,1 #ilosc bajtow
	syscall
	
	lb $t1, ($s6)
	beq $t1, 10, newline
	beq $t1, 0, close_plaintext
	blt $t1, 32, zapisz_wiersz1#czy na pewno znak
	bgt $t1, 95, zapisz_wiersz1
	blt $t1, 65, zapisz_wyjscie
	bgt $t1, 90, zapisz_wyjscie
	jal kodowanie

	sb $t1, ($s7)
	add $s7, $s7, 1
	
	add $s6, $s6, 1
	b zapisz_wiersz1
	
newline:
	la $t1, 13
	
	sb $t1, ($s7)
	add $s7, $s7, 1
	la $t1, 10
	sb $t1, ($s7)
	add $s7, $s7, 1
	add $s6, $s6, 1
	j zapisz_wiersz1
	
	#exit:
	
close_plaintext: #ten fragment (do newline:) zwykle jest przeskakiwany
	li $v0, 16 #zamykanie pliku
	move $a0, $s0
	syscall
	move $s0, $zero

open_cipher:
	li $v0, 13
	la $a0, ciphertext
	li $a1, 1
	li $a2, 0
	syscall
	move $s5, $v0
	
			
write_cipher:
	li $v0, 15
	move $a0, $s5
	la $a1, tablica4
	li $a2, 1024
	syscall

close_cipher:
	li $v0, 16 #zamykanie pliku
	move $a0, $s5
	syscall
	
	la $a0, tablica4
	li $v0, 4
	syscall
	
	li	$v0,10
	syscall
	#zeby wyswietlic debug -> zakomentuj linie powyzej
	
	
	
	
zapisz_wyjscie:
	sb $t1, ($s7)
	add $s7, $s7, 1
	add $s6, $s6, 1
	j zapisz_wiersz1
	
zapisz_drugatab:
		sb $t1,tablica3($t4)
		addu $t4, $t4, 1
		add $t0, $t0, 1
		b zapisz_ciag #loop	

	
zmien_liczbe:
	lb $t1, tablica0($t0)
	beqz $t1,powrot
	subu $t1, $t1, 48 #zmien na cyfre
	mul $t1, $t1, 10 #dziesiatki
	addu $t0, $t0, 1
	lb $t2, tablica0($t0)
	subu $t2, $t2, 48 #zmien na cyfre
	addu $t1, $t1, $t2
	sb $t1,tablicapom($t3)
	addu $t3, $t3, 1
	addu $t0, $t0, 3
	j zmien_liczbe
	
zmien_na_liczbe:
	subu $t1, $t1, 48 #zmien na cyfre
	mul $t1, $t1, 10 #dziesiatki
	addu $t0, $t0, 1
	lb $t2, tablica2($t0)
	subu $t2, $t2, 48 #zmien na cyfre
	addu $t1, $t1, $t2
	#addu $t1, $t1, 65
	jr $ra
	
kodowanie:

	add $t1, $t1, -65
	add $t1, $t1, $t4
	la $t7, 26
	div $t1, $t7
	mfhi $t1
	lb $t2, tablica2($t1)
	add $t2, $t2, 26
		#pozycja 2 rotor
	add $t2, $t2, $t5
	div $t2, $t7
	mfhi $t2
	add $t2, $t2, 26
	lb $t1, tablica2($t2)
	add $t1, $t1, 52
	add $t1, $t1, $t6
	div $t1, $t7
	mfhi $t1
	add $t1, $t1, 52
	
	lb $t2, tablica2($t1)
	add $t2, $t2, 78
	
	
	lb $t1, tablica2($t2)
	#perehodim nazad
	
	lb $t2, tablica3($t1)
	sub $t2, $t2, $t6
	bltz $t2, zamien
	zamieniona:
	add $t2, $t2, 26	
	lb $t1, tablica3($t2)
	sub $t1, $t1, $t5
	bltz $t1, zamien1
	zamieniona1:
	add $t1, $t1, 52
	

	lb $t2, tablica3($t1)
	sub $t2, $t2, $t4
	bltz $t2, zamien2
	zamieniona2:
	
	move $t1, $t2
	addu $t1, $t1, 65
	
	j rotate
	wroc:
	
	jr $ra
	
rotate:

	bge $t4, 25, obroc2
	bgtz $t5, obroc2
	bgtz $t6, obroc2
	add $t4, $t4, 1
	j wroc
obroc2:
	move $t5, $s2
	bgt $t4, 25, obroc3 
	bge $t5, 25, obroc3
	bgtz $t6, obroc3
	move $t4, $zero
	move $s1, $t4
	add $t5, $t5, 1
	move $s2, $t5

	j wroc

obroc3:
	move $t6, $s3
	bgtz $t4, obroc1
	bgt $t5, 25, obroc1
	bge $t6, 25, obroc1
	move $t5, $zero
	move $s2, $t5
	add $t6, $t6, 1
	move $s3, $t6
	j wroc
	
obroc1:
	bgtz $t4, rotate
	bgtz $t5, rotate
	bgt $t6, 25, rotate
	move $t6, $zero
	move $s3, $t6
	add $t4, $t4, 1
	j wroc
	

	
zamien:
	la $t7, 26
	add $t2, $t2,$t7
	
j zamieniona

zamien1:
	la $t7, 26
	add $t1, $t1,$t7
	
j zamieniona1

zamien2:
	la $t7, 26
	add $t2, $t2,$t7
	
j zamieniona2
