#####################################################################
#
# CSC258H5S Fall 2021 Assembly Final Project
# University of Toronto, St. George
#
# Student: Qiyi Zhang, Student Number 10005723291
#
# Bitmap Display Configuration:
# - Unit width in pixels: 8
# - Unit height in pixels: 8
# - Display width in pixels: 256
# - Display height in pixels: 256
# - Base Address for Display: 0x10008000 ($gp)
#
# Which milestone is reached in this submission?
# (See the assignment handout for descriptions of the milestones)
# - Milestone 1/2/3/4/5 (choose the one the applies)
#
# Which approved additional features have been implemented?
# (See the assignment handout for the list of additional features)
# 1. Display the number of lives remaining. 
# 2. After final player death, display game over/retry screen. Restart the game if the ¡°retry¡± option is chosen.
# 3. Display a death/respawn animation each
# 4. Add sound effects for movement, collisions, game end and reaching the goal area.
# 5. Add powerups to scene (slowing down time, score booster, extra lives, etc)



#
.data
wincolor:  .word 0xC6C4FF
byeColor: .word 0x00ffff
displayAddress: .word 0x10008000
GREEN: .word 0x00ff00
BLUE: .word  0x0000ff
BLACK: .word 0x000000
RED: .word 0xEE4B2B
PURPLE: .word 0xFF00FF
BROWN: .word 0XBFAB93
log1:	.word 0x10008400
log2: .word 0x10008608
vehicle1: .word 0x10008a00
vehicle2: .word 0x10008c04
obsArray: .word 4,4,4,4,4,4,4,4,4,4, 4, 16,4,4,4,4,4,4,4, 4,4,4
obsArray1: .word 4,4,4,4,52,4,4,4,4,
FrogArray: .word 0, 12, 116, 4 , 4 , 4,120,4,120,4,4,4
FrogInit: .word 0x10008e30
FrogDe: .word 0x10008e30
pos: .word 0
pos1: .word 640
Mylife: .asciiz "Your have 3 lives reamining, good luck!\n"
moreLife: .asciiz "Your have 3 or more lives! Take your time ! \n"
second: .asciiz "Your have 2 lives reamining, good luck!\n"
one: .asciiz "Your have 1 lives reamining, take care!\n"
power: .asciiz "Your gain an extra life !!! !\n"
retry: .asciiz "You died, press r to retry :)\n"
life: .word 3
MaxLife: .word 3
powerR: 2
powerLimit: 2

.text
Main:	li $v0, 4
	la $a0, Mylife
	syscall

	lw $t0, displayAddress # $t0 stores the base address for display
	li $v0, 32				# Sleep op code
	li $a0, 17		# Sleep 1/20 second 
	li $s7, 0
	lw $t8, FrogDe
	la $t9, FrogInit
	sw $t8, 0($t9)
	lw $t8, MaxLife
	la $t9, life
	sw $t8, 0($t9)
	lw $t8, powerLimit
	la $t9, powerR
	sw $t8, 0($t9)

	la $t9, pos
	sw $zero, 0($t9)
	jal print_powerup
	

	
	syscall

	j Loop
Loop:	beq $s7, 4, Main #If the user enter r, go back to Main
	lw $t0, displayAddress # $t0 stores the base address for display

	
	jal draw
	

	lw $t8, pos1
	la $t9, pos
	sw $t8, 0($t9)
	

	


	jal check_key #get user input (if there is one)

	li $v0, 32
 	li $a0, 120
	 syscall
	 jal update_log1
	jal update_log2
	jal update_v1
	jal update_v2
	jal check_win
	jal check_supply_collision
	

	
	j Loop	

background:  
	addi $sp, $sp, -4
	sw $ra, 0($sp)


	
	j Top	
	
game_over: #from doodle jump
	# draw b
	jal finishMusic

	lw $t0, displayAddress
	addi $t0, $t0, 1576
	lw $t1, byeColor
	sw $t1, 128($t0)
	sw $t1, 256($t0)
	sw $t1, 384($t0)
	sw $t1, 388($t0)
	sw $t1, 392($t0)
	sw $t1, 520($t0)
	sw $t1, 512($t0)
	sw $t1, 640($t0)
	sw $t1, 644($t0)
	sw $t1, 648($t0)
	#draw y
	sw $t1, 400($t0)
	sw $t1, 528($t0)
	sw $t1, 656($t0)
	sw $t1, 408($t0)
	sw $t1, 536($t0)
	sw $t1, 660($t0)
	sw $t1, 664($t0)
	sw $t1, 792($t0)
	sw $t1, 920($t0)
	sw $t1, 916($t0)
	sw $t1, 912($t0)
	#draw E
	sw $t1, 672($t0)
	sw $t1, 676($t0)
	sw $t1, 680($t0)
	sw $t1, 544($t0)
	sw $t1, 416($t0)
	sw $t1, 420($t0)
	sw $t1, 424($t0)
	sw $t1, 288($t0)
	sw $t1, 160($t0)
	sw $t1, 164($t0)
	sw $t1, 168($t0)
	#draw !
	sw $t1, 176($t0)
	sw $t1, 304($t0)
	sw $t1, 432($t0)
	sw $t1, 688($t0)
	
	
	
	
	
	
	li $v0, 32 # sleep
	li $a0, 1000
	li $v0, 4
	la $a0, retry
	syscall
	j Exit
Top: 	
	li $t1, 0x00ff00
	li $t2 0x10008400	
	lw $t4, pos
	sub $t2, $t2, $t4
	beq $t0,, $t2, TopEnd 
	sw $t1, 0($t0)
	addi $t0, $t0, 4 #   $t0 = $t0 + 1
	j Top #   jump back
	
TopEnd: li $t0, 0x10008400
	lW $t1, BLUE
	li $t2, 0x10008800
	j Water
Water: beq $t0,, $t2, WaterEnd
	sw $t1, 0($t0)
	addi $t0, $t0, 4 #   $t0 = $t0 + 1
	j Water #   jump back
WaterEnd: li $t0, 0x10008800
	li $t1, 0xFFFF00
	li $t2, 0x10008a00
	j Safe
Safe: beq $t0,, $t2, SafeEnd 
	sw $t1, 0($t0)
	addi $t0, $t0, 4 #  
	j Safe
SafeEnd: li $t0, 0x10008a00
	lw $t1, BLACK
	li $t2, 0x10008e00
	j CarZoon
CarZoon:beq $t0,, $t2, CarZoonEnd 
	sw $t1, 0($t0)
	addi $t0, $t0, 4 #  
	j CarZoon
CarZoonEnd:
	li $t0, 0x10008e00
	li $t1, 0x00ff00
	li $t2, 0x10009000
Start: beq $t0,, $t2, Back
	sw $t1, 0($t0)
	addi $t0, $t0, 4 #   $t0 = $t0 + 1
	j Start
	

	
	




Draw_logs: 
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	addi $t6, $zero, 23
	addi $t5, $zero, 0
	li $s1, 0x10008400
	lw $t0, log1
	la $t1, obsArray
	addi $a3, $s1, 128
	addi $a1, $t0, 0
	j Draw1
	



Draw1:	
	lw $t2, 0($t1)
	beq $t5, $t6, Back
	addi $t5, $t5, 1
	add $t1, $t1, 4
	lw $a0, BROWN
	jal DrawShape
	add $a1, $t2, $a1
	bge $a1, $a3, Else	
	j Draw1
	
	
Draw_log2: 
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	addi $t6, $zero, 23
	addi $t5, $zero, 0
	li $s1, 0x10008600
	lw $t0, log2
	la $t1, obsArray
	addi $a3, $s1, 128
	addi $a1, $t0, 0
	j Draw1


		
Draw_v:addi $sp, $sp, -4
	sw $ra, 0($sp)
	addi $t5, $zero, 0
	addi $t6, $zero, 11
	li $s1, 0x10008a00
	lw $t0, vehicle1
	la $t1, obsArray1
	addi $a3, $s1, 128
	addi $a1, $t0, 0
	j Draw2
	
Draw2:lw $t2, 0($t1)
	beq $t5, $t6, Back
	addi $t5, $t5, 1
	add $t1, $t1, 4
	lw $a0, RED
	jal DrawShape
	add $a1, $t2, $a1
	bge $a1, $a3, Else
	j Draw2

Draw_v2:addi $sp, $sp, -4
	sw $ra, 0($sp)
	addi $t5, $zero, 0
	addi $t6, $zero, 11
	li $s1, 0x10008c00
	lw $t0, vehicle2
	la $t1, obsArray1
	addi $a3, $s1, 128
	addi $a1, $t0, 0
	j Draw2
	

Back: 	
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	
	jr $ra

Else: 	addi $sp, $sp, -4
	sw $ra, 0($sp)
	subi $a1, $a1, 128
	sub $a1, $a1, $t2

	lw $ra, 0($sp)
	addi $sp, $sp, 4
	jr $ra
Else1: 	
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	subi $a1, $a1, 128
	sub $a1, $a1, $t2
	


	lw $ra, 0($sp)
	addi $sp, $sp, 4
	jr $ra


DrawShape: addi $sp, $sp, -4
	sw $ra, 0($sp)
	
	sw $a0, 0($a1) 	
	addi $t7, $a1, 128
	sw $a0, 0($t7) 
	addi $t7, $t7, 128
	sw $a0, 0($t7) 
	addi $t7, $t7, 128
	sw $a0, 0($t7) 
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	jr $ra



clear_screen: 
	addi $sp, $sp, -4
	sw $ra, 0($sp)

	lw $t0, displayAddress 
	lw $t3, BLACK	
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	li $t4, 0		
	li $t5, 1024
	
clear_screen_loop:
	beq $t4, $t5, game_over
	sw $t3, 0($t0)
	addi $t0, $t0, 4
	
	addi $t4, $t4, 1
	j clear_screen_loop

 	
 	# pop a word off the stack and move the stack pointer
	
	
update_log1: 
	 addi $sp, $sp, -4
	sw $ra, 0($sp)
	la $t5, log1
	lw $t7, log1
	li $t6,	0x10008400
	addi $t6, $t6, 124
	bge $t7,$t6, cut
	addi $t7, $t7, 4
	sw $t7, 0($t5)
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	jr $ra
update_log2: 
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	la $t5, log2
	lw $t7, log2
	li $t6, 0x10008600
	ble $t7,$t6, cut1
	addi $t7, $t7, -4
	sw $t7, 0($t5)
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	jr $ra
	
update_v1: addi $sp, $sp, -4
	sw $ra, 0($sp)
	la $t5, vehicle1
	lw $t7, vehicle1
	li $t6,	0x10008a00
	addi $t6, $t6, 124
	bge $t7,$t6, cut
	addi $t7, $t7, 4
	sw $t7, 0($t5)
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	jr $ra
update_v2: 
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	la $t5, vehicle2
	lw $t7, vehicle2
	li $t6, 0x10008c00
	ble $t7,$t6, cut1
	addi $t7, $t7, -4
	sw $t7, 0($t5)
	lw $ra, 0($sp)
	addi $sp, $sp, 4	
	jr $ra
	
draw: 	addi $sp, $sp, -4
	sw $ra, 0($sp)

	lw $t0, displayAddress 
	
	
	

	jal background
	jal draw_p
	jal Draw_logs

	jal Draw_log2
	jal Draw_v2
	jal Draw_v
	
	jal Frog
	jal check_collision




	
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	
	jr $ra

	

cut: 	addi $sp, $sp, -4
	sw $ra, 0($sp)

	subi $t7, $t7, 124
	sw $t7, 0($t5)
	
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	
	jr $ra
	
cut1:addi $sp, $sp, -4
	sw $ra, 0($sp)

	add $t7, $t7, 124

	sw $t7, 0($t5)
	
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	
	jr $ra
	
Frog:	addi $sp, $sp, -4
	sw $ra, 0($sp)
	addi $t6, $zero, 12
	addi $t5, $zero, 0
	lw $t3, PURPLE
	lw $t4, FrogInit
	la $t2, FrogArray
	j DrawF
DrawF:	
	bge $t5, $t6, Back
	addi $t5, $t5, 1
	lw $s1, 0($t2)
	add $t4, $t4, $s1
	sw $t3, 0($t4)
	addi $t2, $t2, 4
	j DrawF
		
	
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	
	jr $ra
	
	

check_key: 


	# move stack pointer a work and push ra onto it
	addi $sp, $sp, -4 
	sw $ra, 0($sp)
	
	lw $t8, 0xffff0000
	beq $t8, 1, get_keyboard_input # if key is pressed, jump to get this key
	addi $t8, $zero, 0
	
	# pop a word off the stack and move the stack pointer
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	
	jr $ra	
get_keyboard_input:
	# move stack pointer a work and push ra onto it
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	
	lw $t2, 0xffff0004
	addi $v0, $zero, 0	#default case
	beq $t2, 0x77, respond_to_w
	beq $t2, 0x61, respond_to_a
	beq $t2, 0x73, respond_to_s
	beq $t2, 0x64, respond_to_d
	beq $t2, 0x72, respond_to_r

	beq $t2, 0x6c, Exit #exit when l is entered
	
	# pop a word off the stack and move the stack pointer
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	
	jr $ra	
respond_to_w:
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	la $t9, FrogInit
	lw $t8, FrogInit
	addi $t8, $t8, -128	
	sw $t8, 0($t9)
	jal move_sound
	lw $ra, 0($sp)
	addi $sp, $sp, 4

	
	jr $ra
	
respond_to_a:
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	la $t9, FrogInit
	lw $t8, FrogInit
	addi $t8, $t8, -4
	sw $t8, 0($t9)
		jal move_sound
	lw $ra, 0($sp)
	
	addi $sp, $sp, 4

	
	jr $ra

respond_to_s:
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	la $t9, FrogInit
	lw $t8, FrogInit
	addi $t8, $t8, 128	
	sw $t8, 0($t9)
	jal move_sound
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	
	
	jr $ra
	
respond_to_d:
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	la $t9, FrogInit
	lw $t8, FrogInit
	addi $t8, $t8, 4
	sw $t8, 0($t9)
	jal move_sound
	lw $ra, 0($sp)
	addi $sp, $sp, 4

	
	jr $ra
	
respond_to_r:addi $sp, $sp, -4
	sw $ra, 0($sp)

	li $s7, 4
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	jr $ra
	
check_collision:
	addi $sp, $sp, -4 #push $ra
	sw $ra, 0($sp)
	
	addi $v0, $zero, 0	#0-continue, 1-game over

	jal check_Frog

	lw $ra, 0($sp) #pop $ra
	addi $sp, $sp, 4
	
	jr $ra
	
check_Frog:
	addi $sp, $sp, -4 #push $ra
	sw $ra, 0($sp)
	lw $t5, FrogInit
	la $t1,FrogArray
	lw $t2, 0($t1)

	
	

	addi $t3, $zero, 11
	addi $t4, $zero, 0
	li $s4, 0
	j check_Frog1

	
	
check_Frog1:	
	beq $t3, $t4, Back
	lw $t2, 0($t1)
	add $t5, $t5, $t2
	jal, check_river
	jal check_car
	


	addi $t4, $t4, 1
	addi $t1, $t1, 4
	j check_Frog1
	
	
	
	
	

check_river: 
addi $sp, $sp, -4 #push $ra
	sw $ra, 0($sp)

	
	li $t6, 0x10008400
	blt $t5, $t6, Back
	li $t6, 0x10008800
	bgt $t5, $t6, Back
	jal check_river1
	jal check_die
	
	lw $ra, 0($sp) #pop $ra
	addi $sp, $sp, 4
	
	jr $ra

	
check_river1: 
	addi $sp, $sp, -4 #push $ra
	sw $ra, 0($sp)

	addi $a1, $zero, 24
	addi $a2, $zero, 0
	li $s1, 0x10008400
	lw $t0, log1
	lw $s5, log2
	la $s2, obsArray
	addi $s1, $s1, 128
	li $a3, 0x10008600
	addi $a3, $a3, 128
	j c1
	
c1:	
	beq $t5, $t0, go
	addi $t8, $t0, 128
	beq $t5, $t8, go
	addi $t8, $t8, 128
	beq $t5, $t8, go
	addi $t8, $t8, 128
	beq $t5, $t8, go
	
	
	beq $t5, $s5, go
	addi $t8, $s5, 128
	beq $t5, $t8, go
	addi $t8, $t8, 128
	beq $t5, $t8, go
	addi $t8, $t8, 128
	beq $t5, $t8, go
	
	bge $a2, $a1, Back
	addi $a2, $a2, 1
	addi $s2, $s2, 4
	lw $s6, 0($s2)
	add $t0, $t0, $s6
	jal cut2
	add, $s5, $s5, $s6
	jal cut3
	j c1
	
	
	

cut2:addi $sp, $sp, -4 #push $ra
	sw $ra, 0($sp)
	bne $t0, $s1, Back
	
	subi $t0, $t0, 128
	lw $ra, 0($sp) #pop $ra
	addi $sp, $sp, 4
	
	jr $ra
cut3:	addi $sp, $sp, -4 #push $ra
	sw $ra, 0($sp)
	bne $s5, $a3, Back
	sub $t5, $t5, 128
	lw $ra, 0($sp) #pop $ra
	addi $sp, $sp, 4
	
	jr $ra
go: 
	
	li $s4, 2
	
	
	lw $ra, 0($sp) #pop $ra
	addi $sp, $sp, 4
	
	jr $ra
	
	
	
	
check_die:
	addi $sp, $sp, -4 #push $ra
	sw $ra, 0($sp)
	
	bne $s4,2, Again
	
	lw $ra, 0($sp) #pop $ra
	addi $sp, $sp, 4
	
	
	jr $ra
check_car:addi $sp, $sp, -4 #push $ra
	sw $ra, 0($sp)

	
	li $t6, 0x10008a00
	blt $t5, $t6, Back
	li $t6,  0x10008e00
	bgt $t5, $t6, Back
	jal check_car1
	jal check_die1
	
	lw $ra, 0($sp) #pop $ra
	addi $sp, $sp, 4
	
	jr $ra
	

check_car1: 
	addi $sp, $sp, -4 #push $ra
	sw $ra, 0($sp)

	addi $a1, $zero, 11
	addi $a2, $zero, 0
	li $s1,  0x10008a00
	lw $t0, vehicle1
	lw $s5, vehicle2
	la $s2, obsArray1
	addi $s1, $s1, 128
	li $a3, 0x10008c00
	addi $a3, $a3, 128
	j c2
c2:	
	beq $t5, $t0, go
	addi $t8, $t0, 128
	beq $t5, $t8, go
	addi $t8, $t8, 128
	beq $t5, $t8, go
	addi $t8, $t8, 128
	beq $t5, $t8, go
	
	
	beq $t5, $s5, go
	addi $t8, $s5, 128
	beq $t5, $t8, go
	addi $t8, $t8, 128
	beq $t5, $t8, go
	addi $t8, $t8, 128
	beq $t5, $t8, go
	
	bge $a2, $a1, Back
	addi $a2, $a2, 1
	addi $s2, $s2, 4
	lw $s6, 0($s2)
	add $t0, $t0, $s6
	beq $t0, $s1, cut2
	add, $s5, $s5, $s6
	beq $s5, $a3, cut3
	j c2	


	
check_die1:
	addi $sp, $sp, -4 #push $ra
	sw $ra, 0($sp)
	
	beq $s4,2, Again
	
	lw $ra, 0($sp) #pop $ra
	addi $sp, $sp, 4
	
	
	jr $ra
	
Again: jal DeadAnime
	la $t9, life
	lw $t5, 0($t9)
	subi $t5, $t5, 1
	beq $t5, $zero, clear_screen
	bge $t5, 3, moreS
	beq $t5, 2, secondS
	li $v0, 4
	la $a0, one
	syscall
	
	
	
	
	sw $t5, 0($t9)
	li $v0, 32
 	li $a0, 1000
 	syscall

	 jal update_log1
	jal update_log2
	jal update_v1
	jal update_v2
	lw $t8, FrogDe
	la $t9, FrogInit
	sw $t8, 0($t9)
	jal bornMusic

	j Loop

moreS:li $v0, 4
	la $a0, moreLife
	syscall
	
	
	sw $t5, 0($t9)
	li $v0, 32
 	li $a0, 1000
 	syscall

	 jal update_log1
	jal update_log2
	jal update_v1
	jal update_v2
	lw $t8, FrogDe
	la $t9, FrogInit
	sw $t8, 0($t9)
	jal bornMusic

	j Loop	
			
secondS:li $v0, 4
	la $a0, second
	syscall
	
	
	
	
	sw $t5, 0($t9)
	li $v0, 32
 	li $a0, 1000
 	syscall

	 jal update_log1
	jal update_log2
	jal update_v1
	jal update_v2
	lw $t8, FrogDe
	la $t9, FrogInit
	sw $t8, 0($t9)
	jal bornMusic

	j Loop
infinite: beq $s7, 4, Main
	jal check_key
	j infinite
	
DeadAnime: addi $sp, $sp, -4 #push $ra
	sw $ra, 0($sp)
	jal deadMusic
	lw $t0, displayAddress 
	jal background
	jal Draw_logs

	jal Draw_log2
	jal Draw_v2
	jal Draw_v

	jal deadFrog
	lw $ra, 0($sp) #pop $ra
	addi $sp, $sp, 4
	
	
	jr $ra
	
deadFrog: addi $sp, $sp, -4 #push $ra
	sw $ra, 0($sp)
	lw $t1, FrogInit
	lw $t2, PURPLE

	lw $ra, 0($sp) #pop $ra
	addi $sp, $sp, 4
	sw $t2, 0($t1)
	sw $t2, 12($t1)
	sw $t2, 132($t1)
	sw $t2, 136($t1)
	sw $t2, 260($t1)
	sw $t2, 264($t1)
	sw $t2, 384($t1)
	sw $t2, 396($t1)
	
	
	li $v0, 32
 	li $a0, 1000
	 syscall
	
	
	jr $ra
	
check_win: addi $sp, $sp, -4 #push $ra
	sw $ra, 0($sp)
	lw $t1, FrogInit
	addi $t1, $t1, 512
	li $t2, 0x10008400
	ble $t1, $t2, winS
	lw $ra, 0($sp) #pop $ra
	addi $sp, $sp, 4
	
	
	jr $ra
	
	
	
winS: addi $sp, $sp, -4 #push $ra
	sw $ra, 0($sp)
	jal WinAnime
	
	
	li $v0, 32
 	li $a0, 1000
	 syscall
	
	
	
	lw $t8, FrogDe
	la $t9, FrogInit
	sw $t8, 0($t9)
	

	lw $ra, 0($sp) #pop $ra
	addi $sp, $sp, 4
	
	
	jr $ra
	
WinAnime: addi $sp, $sp, -4 #push $ra
	sw $ra, 0($sp)
	lw $t0, displayAddress 
	jal background
	jal Draw_logs

	jal Draw_log2
	jal Draw_v2
	jal Draw_v
	jal winMusic

	jal LiveFrog

	lw $ra, 0($sp) #pop $ra
	addi $sp, $sp, 4
	
	
	jr $ra
	
LiveFrog: addi $sp, $sp, -4 #push $ra
	sw $ra, 0($sp)
	lw $t1, FrogInit
	lw $t2, wincolor

	lw $ra, 0($sp) #pop $ra
	addi $sp, $sp, 4
	sw $t2, 0($t1)
	sw $t2, 12($t1)
	sw $t2, 256($t1)
	sw $t2, 268($t1)
	sw $t2, 388($t1)
	sw $t2, 392($t1)

	
	
	li $v0, 32
 	li $a0, 2000
	 syscall
	
	
	jr $ra


bornMusic: addi $sp, $sp, -4 #push $ra
	sw $ra, 0($sp)
	li $v0, 31
	li $a0, 63
	li $a1,2000
	li $a2, 120
	li $a3,80
	syscall
	
	lw $ra, 0($sp) #pop $ra
	addi $sp, $sp, 4
	
	
	jr $ra
	
deadMusic: 
addi $sp, $sp, -4 #push $ra
	sw $ra, 0($sp)
li $v0, 31
li $a0, 72
li $a1, 2000
li $a2, 118
li $a3, 120
syscall
lw $ra, 0($sp) #pop $ra
	addi $sp, $sp, 4
	
	
	jr $ra
	
winMusic:
addi $sp, $sp, -4 #push $ra
	sw $ra, 0($sp)
li $v0, 31
li $a0, 65
li $a1, 2000
li $a2, 112
li $a3, 120
syscall
li $v0, 31
li $a0, 65
li $a1, 2000
li $a2, 123
li $a3, 120
syscall
lw $ra, 0($sp) #pop $ra
	addi $sp, $sp, 4
	
	
	jr $ra
	
move_sound:
addi $sp, $sp, -4 #push $ra
	sw $ra, 0($sp)
li $v0, 31

li $a0, 70
li $a1, 150
li $a2, 115
li $a3, 120
syscall
lw $ra, 0($sp) #pop $ra
addi $sp, $sp, 4
	
	
jr $ra
	
finishMusic:
addi $sp, $sp, -4 #push $ra
	sw $ra, 0($sp)
li $v0, 31
li $a0, 70
li $a1, 1000
li $a2,127
li $a3, 120
syscall
lw $ra, 0($sp) #pop $ra
addi $sp, $sp, 4
	
	
jr $ra


get_random:
	addi $sp, $sp, -4 #push $ra
	sw $ra, 0($sp)
  	li $v0, 42       
  	li $a0, 0   
  	li $a1, 32
  	syscall        
  	sll $a0, $a0, 2
  	addi $a0, $a0, 2176

  	lw $ra, 0($sp) #pop $ra
	addi $sp, $sp, 4
	
	
	jr $ra


  	
 print_powerup:
 	addi $sp, $sp, -4 #push $ra
	sw $ra, 0($sp)
	lw $t2, powerR
	beq $t2, 0, NoP

	jal get_random
 	 lw $t0, displayAddress
 	 add $t0, $t0, $a0
 	 lw $t4, wincolor
 	 sw $t4, 0($t0)
 	 add $k1, $zero, $t0
 	 la $t1, powerR
 	 lw $t2, powerR

 	 subi $t2, $t2, 1
 	 sw $t2, 0($t1)
 	 
 	 
 	 
 	 
 	 lw $ra, 0($sp) #pop $ra
	addi $sp, $sp, 4
	jr $ra
	
 draw_p:addi $sp, $sp, -4 #push $ra
	sw $ra, 0($sp)
	jal get_random
 	lw $t4, wincolor
 	 sw $t4, 0($k1)
 	  	 lw $ra, 0($sp) #pop $ra
	addi $sp, $sp, 4
	jr $ra
	
check_supply_collision:
	addi $sp, $sp, -4 #push $ra
	sw $ra, 0($sp)
	lw $t1, FrogInit
	addi $t2, $t1, 132
	addi $t1, $t2, 4
	beq $k1, $t1, score
	beq $k1, $t2, score
	lw $ra, 0($sp) #pop $ra
	addi $sp, $sp, 4
	jr $ra
score: jal print_powerup
	li $v0, 4
	la $a0, power
	syscall
	la $t1, life
	lw $t2, life
	addi $t2, $t2, 1
	sw $t2, 0($t1)
	lw $ra, 0($sp) #pop $ra
	addi $sp, $sp, 4
	jr $ra
NoP: lw $k1, displayAddress
	lw $ra, 0($sp) #pop $ra
	addi $sp, $sp, 4
	jr $ra

Exit:
jal infinite
li $v0, 10 # terminate the program gracefully


syscall


