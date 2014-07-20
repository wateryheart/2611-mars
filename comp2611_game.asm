#Name: MAR Chun Sum Connie
#ID: 20057384
#Email: csmar@stu.ust.hk

.data
title: 		.asciiz "COMP2611 Game"
game_win:	.asciiz "You Win! Enjoy the game brought by COMP2611!"
game_lose:	.asciiz "Come on! It's an easy game!"
input_dolphin:	.asciiz "Enter the number of Dolphins(1-20): "
input_dolphin_nos:	.asciiz "Number of dolphin should be between 1 to 20! \n "
input_subma:	.asciiz "Enter the number of Submarines (1-20): "
input_subma_nos:	.asciiz "Number of submarine should be between 1 to 20! \n "
input_bombs:	.asciiz "Enter the number of Simple Bombs(1-20): "
input_bombs_nos:	.asciiz "Number of simple bomb should be between 1 to 20! \n "
input_rbombs:	.asciiz "Enter the number of Remote Bombs(1-20): "
input_rbombs_nos:	.asciiz "Number of remote bomb should be between 1 to 20! \n "
width:		.word 800 # the width of the screen
height:		.word 600 # the height of the screen
subma_ids:	.word -1:20 # used to keep track of the ids of submarines
subma_locs:	.word -1:40 # the array of initialized locations of submarines
subma_base:	.word 2 # base id of sumbarine
subma_num: 	.word 0 # the number of submarines
dolphin_ids:	.word -1:20 # used to keep track of the ids of dolphins
dolphin_locs:	.word -1:40 # the array of initialized locations of dolphins
dolphin_base:	.word 22 # base id of dolphin
dolphin_num: 	.word 0 # the number of dolphins
bomb_ids: 	.word -1:20 # used to keep track of the ids of bombs
bomb_base:	.word 42 # base id of the simple bomb
bomb_num:	.word 0 # the number of simple bombs
bomb_count:	.word 0 # the "running" number of simple bombs
rbomb_ids:	.word -1:20 # used to keep track of the ids of remote bombs
rbomb_base:	.word 62 # base id of the remote bomb
rbomb_num:	.word 0 # the number of remote bombs
rbomb_count:	.word 0 # the "running" number of remote bombs
abomb_ids: 	.word -1:20 # used to keep track of the ids of bombs active on the screen
arbomb_ids: 	.word -1:20 # used to keep track of the ids of bombs active on the screen

.text
main:		la $a0, title
		la $t0, width
		lw $a1, 0($t0)
		la $t0, height
		lw $a2, 0($t0)
		li $v0, 100 # Create the Game Screen
		syscall
	
		addi $sp, $sp, -16
		jal input_game_params
		lw $a0, 12($sp) # num of dolphin
		lw $a1, 8($sp) # num of submarine
		lw $a2, 4($sp) # num of bombs
		lw $a3, 0($sp) # num of remote bombs
		addi $sp, $sp, 16
		# Task1: Initialize the game by create Game Objects based on game level
		jal init_game

		add $a0, $zero, $zero
		addi $a1, $zero, 1
		li $v0, 105
		syscall # play the background sound
		
m_loop:		jal get_time
		add $s6, $v0, $zero # $s6: starting time of the game
		jal check_game_end
		bne $v0, $zero, game_end
		jal update_object_status	
		jal process_input
		jal check_bomb_hits
		jal move_ship
		jal move_dolphins
		jal move_submarines
		jal move_bombs
		jal move_rbombs
		jal update_score
		# refresh screen
		li $v0, 119
		syscall
		add $a0, $s6, $zero
		addi $a1, $zero, 30 # iteration gap: 30 milliseconds
		jal have_a_nap
		j m_loop
game_end:	add $s2, $v0, $zero # $s2: the game status
		add $a0, $zero, $zero # stop background sound
		li $v0, 122
		syscall
		addi $a0, $zero, -2 # special id for win_text
		addi $a1, $zero, 80
		addi $a2, $zero, 280
		addi $t0, $zero, 1
		beq $s2, $t0, win
		la $a3, game_lose # game lose
		li $v0, 104
		syscall
		li $v0, 119
		syscall # refresh screen
		addi $a0, $zero, 3
		add $a1, $zero, $zero
		li $v0, 105 # play sound: lose
		syscall 
		j game_pause
win:		la $a3, game_win
		li $v0, 104
		syscall # game win
		li $v0, 119
		syscall # refresh screen
		addi $a0, $zero, 4
		add $a1, $zero, $zero
		li $v0, 105
		syscall
game_pause:	add $a0, $s6, $zero
		addi $a1, $zero, 600
		jal have_a_nap
		li $v0, 10
		syscall

#--------------------------------------------------------------------
# func: input_game_params
# get the following information interactively from the user:
# 1) number of dolphins; 2) number of submarines;
# 3) number of simple bombs; 4) number of remote bombs;
# the results will be placed in the caller's stack space.
#--------------------------------------------------------------------
input_game_params:	addi $sp, $sp, -4
			sw $ra, 0($sp)

#dolphins
input_dolphin_no:		la $a0, input_dolphin
			li $v0, 4
			syscall # print string
			li $v0, 5
			syscall # read integer
			
			slti $t0,$v0,1
			beqz $t0, check_max_dolphin_no #if (dolphine number>=1) then check_max_dolphin_no
			j error_dolphin_no #if (dolphine number<1) then error_dolphin_no

check_max_dolphin_no:	slti $t1,$v0,21	
			beqz $t1,error_dolphin_no #if (dolphine number>=21) then error_dolphin_no	
			j store_dolphin_no #if (dolphine number<21) then store_dolphin_no
						
error_dolphin_no:		la $a0, input_dolphin_nos
			li $v0, 4
			syscall # print error string	
			j input_dolphin_no
			
store_dolphin_no:		sw $v0, 16($sp) # store number of dolphins

#submarine			
input_subma_no:		la $a0, input_subma
			li $v0, 4
			syscall
			li $v0, 5
			syscall
			
			slti $t0,$v0,1
			beqz $t0, check_max_subma_no #if (subma number>=1) then check_max_subma_no
			j error_subma_no #if (subma number<1) then error_subma_no

check_max_subma_no:	slti $t1,$v0,21	
			beqz $t1,error_subma_no #if (subma number>=21) then error_subma_no	
			j store_subma_no #if (subma number<21) then store_subma_no
						
error_subma_no:		la $a0, input_subma_nos
			li $v0, 4
			syscall # print error string	
			j input_subma_no
			
store_subma_no:		sw $v0, 12($sp) # store number of submarines

#bombs					
input_bombs_no:		la $a0, input_bombs
			li $v0, 4
			syscall
			li $v0, 5
			syscall
			
			slti $t0,$v0,1
			beqz $t0, check_max_bombs_no #if (bombsnumber>=1) then check_max_bombs_no
			j error_bombs_no #if (bombs number<1) then error_bombs_no

check_max_bombs_no:	slti $t1,$v0,21	
			beqz $t1,error_bombs_no #if (bombs number>=21) then error_bombs_no	
			j store_bombs_no #if (bombs number<21) then store_bombs_no
						
error_bombs_no:		la $a0, input_bombs_nos
			li $v0, 4
			syscall # print error string	
			j input_bombs_no
			
store_bombs_no:		sw $v0, 8($sp) # store number of simple bombs

#rbombs			
input_rbombs_no:		la $a0, input_rbombs
			li $v0, 4
			syscall
			li $v0, 5
			syscall
			
			slti $t0,$v0,1
			beqz $t0, check_max_rbombs_no #if (rbombs number>=1) then check_max_rbombs_no
			j error_rbombs_no #if (rbombs number<1) then error_rbombs_no

check_max_rbombs_no:	slti $t1,$v0,21	
			beqz $t1,error_rbombs_no #if (rbombs number>=21) then error_rbombs_no	
			j store_rbombs_no #if (rbombs number<21) then store_rbombs_no
						
error_rbombs_no:		la $a0, input_rbombs_nos
			li $v0, 4
			syscall # print error string	
			j input_rbombs_no
			
store_rbombs_no:		sw $v0, 4($sp) # store the number of remote bombs
			
igp_exit:			lw $ra, 0($sp)
			addi $sp, $sp, 4
			jr $ra

#--------------------------------------------------------------------
# func: init_game (num_dolphin, num_submarins, num_simple_boms, 
#                  num_remote_bombs)
# 1. create the ship: located at the point (320, 90)
# 2. create dolphins and submarines; 
#    their locations and directions are randomly fixed.
# 3. init the ids for simple bombs and remote bombs
#--------------------------------------------------------------------
init_game:
	addi $sp, $sp, -20
	sw $ra, 16($sp)
	sw $s0, 12($sp)
	sw $s1, 8($sp)
	sw $s2, 4($sp)
	sw $s3, 0($sp)
	add $s0, $a0, $zero # $s0 = num_dolphin
	add $s1, $a1, $zero # $s1 = num_submarin
	add $s2, $a2, $zero # $s2 = num_bomb
	add $s3, $a3, $zero # $s3 = num_rbomb
	# 1. create the ship
	li $v0, 101
	li $a0, 1 # the id of ship is 1
	li $a1, 320 # the x_loc of ship
	li $a2, 90 # the y_loc of ship
	li $a3, 2 # set the speed
	syscall
	# 2. create the specified number of dolphins
	add $a0, $s0, $zero
	jal create_multi_dolphins
	la $t0, dolphin_num # keep the record of the num of dolphins
	sw $s0, 0($t0)
	# 3. create the specified number of submarines
	add $a0, $s1, $zero
	jal create_multi_submarines
	la $t0, subma_num # keep the record of the num of submarines
	sw $s1, 0($t0)
	# 4. init simple bombs ids and remote bombs ids
	add $a0, $s2, $zero
	add $a1, $s3, $zero
	jal init_bomb_settings
	# refresh screen
	li $v0, 119
	syscall
ig_exit:
	lw $ra, 16($sp)
	lw $s0, 12($sp)
	lw $s1, 8($sp)
	lw $s2, 4($sp)
	lw $s3, 0($sp)
	addi $sp, $sp, 20
	jr $ra

#--------------------------------------------------------------------
# func create_multi_dolphins(num)
# @num: the number of dolphins
# Create multiple dolphins on the Game Screen.
#--------------------------------------------------------------------
create_multi_dolphins:
	addi $sp, $sp, -20
	sw $ra, 16($sp)
	sw $s0, 12($sp) # totoal num
	sw $s1, 8($sp) # created num
	add $s0, $a0, $zero
	add $s1, $zero, $zero
cmd_be:	beq $s0, $zero, cmd_exit # whether num <= 0
	# get random x_loc: 4($sp)
	add $a0, $s1, $zero
	jal get_dolphin_unintersect_xloc
	sw $v0, 4($sp)
	# get random y_loc
	add $a0, $s1, $zero
	jal get_dolphin_unintersect_yloc
	sw $v0, 0($sp)
	# create one dolphin
	li $v0, 103
	# calculate id
	la $t0, dolphin_base
	lw $t1, 0($t0)
	add $a0, $t1, $s1 # set id
	lw $a1, 4($sp)
	lw $a2, 0($sp)
	addi $a3, $zero, 5 # dolphin speed
	# before syscall, save id, (x_loc, y_loc)
	la $t0, dolphin_ids
	add $t1, $s1, $zero
	sll $t1, $t1, 2
	add $t1, $t1, $t0
	sw $a0, 0($t1) # save id
	la $t0, dolphin_locs
	add $t1, $s1, $zero
	sll $t1, $t1, 3
	add $t1, $t1, $t0
	sw $a1, 0($t1) # save x_loc
	sw $a2, 4($t1) # save y_loc
	syscall
	# to create next one
	addi $s0, $s0, -1
	addi $s1, $s1, 1
	j cmd_be	
cmd_exit:	lw $ra, 16($sp)
		lw $s0, 12($sp)
		lw $s1, 8($sp)
		addi $sp, $sp, 20
		jr $ra

#--------------------------------------------------------------------
# func create_multi_submarines(num)
# @num: the number of submarines
# Create multiple submarines on the Game Screen.
#--------------------------------------------------------------------
create_multi_submarines:
		addi $sp, $sp, -20
		sw $ra, 16($sp)
		sw $s0, 12($sp) # totoal num
		sw $s1, 8($sp) # created num
		add $s0, $a0, $zero
		add $s1, $zero, $zero
cms_be:		beq $s0, $zero, cms_exit # whether num <= 0
		# get random x_loc: 4($sp)
		add $a0, $s1, $zero
		jal get_submarine_unintersect_xloc
		sw $v0, 4($sp)
		# get random y_loc
		add $a0, $s1, $zero
		jal get_submarine_unintersect_yloc
		sw $v0, 0($sp)
		# create one submarine
		li $v0, 102
		# calculate id
		la $t0, subma_base
		lw $t1, 0($t0)
		add $a0, $t1, $s1 # set id
		lw $a1, 4($sp)
		lw $a2, 0($sp)
		addi $a3, $zero, 6 # submarine speed
		# before syscall, save id, (x_loc, y_loc)
		la $t0, subma_ids
		add $t1, $s1, $zero
		sll $t1, $t1, 2
		add $t1, $t1, $t0
		sw $a0, 0($t1) # save id
		la $t0, subma_locs
		add $t1, $s1, $zero
		sll $t1, $t1, 3
		add $t1, $t1, $t0
		sw $a1, 0($t1) # save x_loc
		sw $a2, 4($t1) # save y_loc
		syscall
		addi $s0, $s0, -1 # to create next one
		addi $s1, $s1, 1
		j cms_be	
cms_exit:	lw $ra, 16($sp)
		lw $s0, 12($sp)
		lw $s1, 8($sp)
		addi $sp, $sp, 20
		jr $ra

#--------------------------------------------------------------------
# func get_dolphin_unintersect_xloc(count):
# Get a random value, used as the x_loc for the newly to be created 
# Dolphin.
# The key is to make sure that it does not intersect with any existing
# Dolphins.
# @count: exisiting number of dolphins
#--------------------------------------------------------------------
get_dolphin_unintersect_xloc:
		addi $sp, $sp, -12
		sw $ra, 8($sp)
		sw $s0, 4($sp)
		sw $s1, 0($sp)
		add $s0, $a0, $zero
gdux_loop:	addi $s1, $s0, -1
		li $v0, 42
		li $a0, 50
		li $a1, 700 # the returned random int is int $a0
		syscall
		add $v0, $a0, $zero # now $v0 is the random input
		slt $t1, $s1, $zero
		bne $s1, $zero, gdux_exit
		la $t0, dolphin_locs
gdux_inner:	sll $t1, $s1, 1 # $t1 = $s1 * 2, now corresponds to x_loc offset in word
		sll $t2, $t1, 2 # $t2: now corresponds to x_loc offset in byte
		add $t1, $t2, $t0 # $t1: now the place where x_loc value is
		lw $t2, 0($t1) # $t2: now the value of x_loc
		# check $v0 and $t2 whether intersect
		slt $t3, $v0, $t2 # if v0 < $t2
		bne $t3, $zero, gdux_label1 # if v0 < $t2 go to gdux_label1
		addi $t2, $t2, 60 # then v0 >= $t2
		slt $t3, $v0, $t2
		bnez $t3, gdux_loop # intersection detected!
		j gdux_nextloop
gdux_label1:	addi $t4, $v0, 60
		slt $t3, $t4, $t2
		beq $t3, $zero, gdux_loop # intersection detected! Restart again!
gdux_nextloop:	addi $s1, $s1, -1
		# check $s1 < 0, if yes, we have founded the need x_loc in $v0
		slt $t3, $s1, $zero
		bnez $t3, gdux_exit
		j gdux_inner
gdux_exit:	lw $ra, 8($sp)
		lw $s0, 4($sp)
		lw $s1, 0($sp)
		addi $sp, $sp, 12
		jr $ra

#--------------------------------------------------------------------
# func get_dolphin_unintersect_yloc(count):
# Get a random value, used as the y_loc for the newly to be created 
# Dolphin. 
# Constraint: (150 <= y_loc <= 500)
# The key is to make sure that it does not intersect with any existing
# Dolphins.
# @count: exisiting number of dolphins
#--------------------------------------------------------------------
get_dolphin_unintersect_yloc:
		addi $sp, $sp, -12
		sw $ra, 8($sp)
		sw $s0, 4($sp)
		sw $s1, 0($sp)
		add $s0, $a0, $zero
gduy_loop:	addi $s1, $s0, -1
		li $v0, 42
		li $a0, 50
		li $a1, 500 # now $a0 is the random input
		syscall
		add $v0, $a0, $zero # now $v0 is the random input
		slti $t0, $v0, 150
		beq $t0, $zero, gduy_beg
		addi $v0, $v0, 150
		# 150 <= $v0 <= 500
		slt $t1, $s1, $zero
gduy_beg:	bne $s1, $zero, gduy_exit
		la $t0, dolphin_locs
gduy_inner:	sll $t2, $s1, 1 # $t2 = $s1 * 2
		addi $t1, $t2, 1 # $t1: now corresponds to y_loc offset in word
		sll $t2, $t1, 2 # $t2: now corresponds to y_loc offset in byte
		add $t1, $t2, $t0 # $t1: now the place where y_loc value is
		lw $t2, 0($t1) # $t2: now the value of y_loc
		# check $v0 and $t2 whether intersect
		slt $t3, $v0, $t2 # if v0 < $t2
		bne $t3, $zero, gduy_label1 # if v0 < $t2 go to gdux_label1
		addi $t2, $t2, 40 # then v0 >= $t2
		slt $t3, $v0, $t2
		bnez $t3, gduy_loop # intersection detected!
		j gduy_nextloop
gduy_label1:	addi $t4, $v0, 40
		slt $t3, $t4, $t2
		beq $t3, $zero, gduy_loop # intersection detected! Restart again!
gduy_nextloop:	addi $s1, $s1, -1
		# check $s1 < 0, if yes, we have founded the need x_loc in $v0
		slt $t3, $s1, $zero
		bnez $t3, gduy_exit
		j gduy_inner
gduy_exit:	lw $ra, 8($sp)
		lw $s0, 4($sp)
		lw $s1, 0($sp)
		addi $sp, $sp, 12
		jr $ra

#--------------------------------------------------------------------
# func get_submarine_unintersect_xloc(count):
# Get a random value, used as the x_loc for the newly to be created 
# Dolphin.
# The key is to make sure that it does not intersect with any existing
# Submarines.
# @count: exisiting number of submarines
#--------------------------------------------------------------------
get_submarine_unintersect_xloc:
		addi $sp, $sp, -12
		sw $ra, 8($sp)
		sw $s0, 4($sp)
		sw $s1, 0($sp)
		add $s0, $a0, $zero
gsux_loop:	addi $s1, $s0, -1
		li $v0, 42
		li $a0, 50
		li $a1, 700 # the returned random int is int $a0
		syscall
		add $v0, $a0, $zero # now $v0 is the random input
		slt $t1, $s1, $zero
		bne $s1, $zero, gsux_exit
		la $t0, subma_locs
gsux_inner:	sll $t1, $s1, 1 # $t1 = $s1 * 2, now corresponds to x_loc offset in word
		sll $t2, $t1, 2 # $t2: now corresponds to x_loc offset in byte
		add $t1, $t2, $t0 # $t1: now the place where x_loc value is
		lw $t2, 0($t1) # $t2: now the value of x_loc
		# check $v0 and $t2 whether intersect
		slt $t3, $v0, $t2 # if v0 < $t2
		bne $t3, $zero, gsux_label1 # if v0 < $t2 go to gsux_label1
		addi $t2, $t2, 80 # then v0 >= $t2
		slt $t3, $v0, $t2
		bnez $t3, gsux_loop # intersection detected!
		j gsux_nextloop
gsux_label1:	addi $t4, $v0, 60
		slt $t3, $t4, $t2
		beq $t3, $zero, gsux_loop # intersection detected! Restart again!
gsux_nextloop:	addi $s1, $s1, -1
		# check $s1 < 0, if yes, we have founded the need x_loc in $v0
		slt $t3, $s1, $zero
		bnez $t3, gsux_exit
		j gsux_inner
gsux_exit:	lw $ra, 8($sp)
		lw $s0, 4($sp)
		lw $s1, 0($sp)
		addi $sp, $sp, 12
		jr $ra

#--------------------------------------------------------------------
# func get_submarine_unintersect_yloc(count):
# Get a random value, used as the y_loc for the newly to be created 
# Submarine. 
# Constraint: (200 <= y_loc <= 500)
# The key is to make sure that it does not intersect with any existing
# Submarine.
# @count: exisiting number of dolphins
#--------------------------------------------------------------------
get_submarine_unintersect_yloc:
		addi $sp, $sp, -12
		sw $ra, 8($sp)
		sw $s0, 4($sp)
		sw $s1, 0($sp)
		add $s0, $a0, $zero
gsuy_loop:	addi $s1, $s0, -1
		li $v0, 42
		li $a0, 50
		li $a1, 500 # now $a0 is the random input
		syscall
		add $v0, $a0, $zero # now $v0 is the random input
		slti $t0, $v0, 150
		beq $t0, $zero, gsuy_beg
		addi $v0, $v0, 200
		# 200 <= $v0 <= 500
		slt $t1, $s1, $zero
gsuy_beg:	bne $s1, $zero, gsuy_exit
		la $t0, subma_locs
gsuy_inner:	sll $t2, $s1, 1 # $t2 = $s1 * 2
		addi $t1, $t2, 1 # $t1: now corresponds to y_loc offset in word
		sll $t2, $t1, 2 # $t2: now corresponds to y_loc offset in byte
		add $t1, $t2, $t0 # $t1: now the place where y_loc value is
		lw $t2, 0($t1) # $t2: now the value of y_loc
		# check $v0 and $t2 whether intersect
		slt $t3, $v0, $t2 # if v0 < $t2
		bne $t3, $zero, gsuy_label1 # if v0 < $t2 go to gdux_label1
		addi $t2, $t2, 40 # then v0 >= $t2
		slt $t3, $v0, $t2
		bnez $t3, gsuy_loop # intersection detected!
		j gsuy_nextloop
gsuy_label1:	addi $t4, $v0, 40
		slt $t3, $t4, $t2
		beq $t3, $zero, gsuy_loop # intersection detected! Restart again!
gsuy_nextloop:	addi $s1, $s1, -1
		# check $s1 < 0, if yes, we have founded the need x_loc in $v0
		slt $t3, $s1, $zero
		bnez $t3, gsuy_exit
		j gsuy_inner
gsuy_exit:	lw $ra, 8($sp)
		lw $s0, 4($sp)
		lw $s1, 0($sp)
		addi $sp, $sp, 12
		jr $ra
		
#--------------------------------------------------------------------
# func init_bomb_settings(num_bombs, num_rbombs)
# Initialize the "data structure" for simple bombs and remote bombs:
# bomb_ids, bomb_num = @num_bombs, bomb_count = 0;
# rbomb_ids, rbomb_num = @num_rbombs, rbomb_count = 0;
#--------------------------------------------------------------------
init_bomb_settings:
		addi $sp, $sp, -16
		sw $ra, 12($sp)
		sw $s0, 8($sp)
		sw $s1, 4($sp)
		sw $s2, 0($sp)
		add $s0, $a0, $zero # $s0 = num_bombs
		add $s1, $a1, $zero # $s1 = num_rbombs
		la $t0, bomb_num # bomb_num = $a0
		sw $s0, 0($t0)
		la $t0, rbomb_num # rbomb_num = $a1
		sw $s1, 0($t0)
		add $a0, $s0, $zero
		add $a1, $s1, $zero
		li $v0, 123
		syscall # update bomb number info
		la $t0, bomb_count # bomb_count = 0
		sw $zero, 0($t0)
		la $t0, rbomb_count # rbomb_count = 0
		sw $zero, 0($t0)
		# set $s0 ids for bomb_ids
		la $t0, bomb_base
		lw $s2, 0($t0) # $s2 = base_id for simple bomb
		la $t0, bomb_ids # $t0 = starting address of bomb_ids
ibs_bb:		beq $s0, $zero, ibs_be # finish bomb id setting
		addi $t1, $s0, -1
		sll $t1, $t1, 2
		add $t1, $t1, $t0
		sw $s2, 0($t1)
		addi $s2, $s2, 1
		addi $s0, $s0, -1
		j ibs_bb
		# set $s1 ids for rbomb_ids
ibs_be:		la $t0, rbomb_base
		lw $s2, 0($t0) # $s2 = base_id for remote bomb
		la $t0, rbomb_ids # $t0 = starting address of rbomb_ids	
ibs_rb:		beq $s1, $zero, ibs_exit # finish remote bomb id setting
		addi $t1, $s1, -1
		sll $t1, $t1, 2
		add $t1, $t1, $t0
		sw $s2, 0($t1)
		addi $s2, $s2, 1
		addi $s1, $s1, -1
		j ibs_rb
ibs_exit:	lw $ra, 12($sp)
		lw $s0, 8($sp)
		lw $s1, 4($sp)
		lw $s2, 0($sp)
		addi $sp, $sp, 16
		jr $ra

#--------------------------------------------------------------------
# func process_input
# Read the keyboard input and handle it!
#--------------------------------------------------------------------
process_input:	addi $sp, $sp, -4
		sw $ra, 0($sp)
		jal get_keyboard_input # $v0: the return value
		addi $t0, $zero, 115 # corresponds to key 's'
		beq $v0, $t0, pi_emit_bomb
		addi $t0, $zero, 114 # corresponds to key 'r'
		beq $v0, $t0, pi_emit_rbomb
		addi $t0, $zero, 97 # corresponds to key 'a'
		beq $v0, $t0, pi_activate_rbombs
		j pi_exit
pi_emit_bomb:	jal emit_one_bomb
		j pi_exit
pi_emit_rbomb:	jal emit_one_rbomb
		j pi_exit
pi_activate_rbombs:
		jal activate_rbombs
pi_exit:	lw $ra, 0($sp)
		addi $sp, $sp, 4
		jr $ra

#--------------------------------------------------------------------
# func emit_one_bomb
# 1. check whether there are avaiable bombs to use.
# 2. if yes, create one bomb object
#--------------------------------------------------------------------
emit_one_bomb:	addi $sp, $sp, -28
		sw $ra, 24($sp)
		sw $s0, 20($sp)
		sw $s1, 16($sp)
		sw $s2, 12($sp)
		sw $s3, 8($sp)		
		
		la $t4, rbomb_num
		lw $s2,0($t4)
		la $t4, rbomb_count
		lw $s3,0($t4)
		la $t4, bomb_num
		lw $s0,0($t4)
		la $t4, bomb_count
		lw $s1,0($t4)
		
		beq $s0,$s1 emit_bomb_exit #if(no. of bomb == no. of rining bomb) then emit_bomb_exit
		#else
		#get location of ship
		li $v0, 110
		li $a0, 1 # id of ship
		syscall
		add $t0, $v0, $zero #ship.x
		add $t1, $v1, $zero # ship.y
		
		#create bomb
		la $t4, abomb_ids
		lw $t5, 0($t4)
		addi $t2, $zero,0 #the $t2 th bomb being checked
		
cb_loop:		addi $t6,$zero,20
		beq $t2,$t6,emit_bomb_exit #if (checked 20 bombs) then emit_bomb_exit
		sll $t3,$t2,2
		add $t3,$t3,$t4
		addi $t6,$zero,-1
		lw $t5,0($t3)
		bne $t5,$t6, cb_next_loop #if($t5 != -1) then find next id
		#else create bomb with id :42 + $t2
		
		li $v0, 105 #play sound of emit bomb
		addi $a0,$zero,2
		addi $a1,$zero,0
		syscall
		
		addi $a0,$t2,42 #a0 = id of bomb	
		sw $a0,0($t3) #store id	
		addi $a1,$t0,65	#x_loc of bomb
		addi $a2,$t1,60 #y_loc of bomb
		addi $a3,$zero,4 #speed of bomb
		li $v0,106
		syscall
		
		#update amount of bomb
		addi $s1,$s1,1
		la $t4, bomb_count
		sw $s1,	0($t4)	
		li $v0,123
		sub $a0,$s0,$s1
		sub $a1,$s2,$s3
		syscall
		j emit_bomb_exit
		
cb_next_loop:	addi $t2,$t2,1
		j cb_loop
		
emit_bomb_exit:	lw $s3,8($sp)
		lw $s2,12($sp)
		lw $s1,16($sp)
		lw $s0,20($sp)
		lw $ra,24($sp)
		addi $sp, $sp, 28
		jr $ra
#--------------------------------------------------------------------
# func emit_one_rbomb
# 1. check whether there are avaiable remote bombs to use.
# 2. if yes, create one remote bomb object
#--------------------------------------------------------------------
emit_one_rbomb:	addi $sp, $sp, -28
		sw $ra, 24($sp)
		sw $s0, 20($sp)
		sw $s1, 16($sp)
		sw $s2, 12($sp)
		sw $s3, 8($sp)		
		
		la $t4, rbomb_num
		lw $s2,0($t4)
		la $t4, rbomb_count
		lw $s3,0($t4)
		la $t4, bomb_num
		lw $s0,0($t4)
		la $t4, bomb_count
		lw $s1,0($t4)
		
		beq $s2,$s3 emit_rbomb_exit #if(no. of rbomb == no. of rining rbomb) then emit_rbomb_exit
		#else
		#get location of ship
		li $v0, 110
		li $a0, 1 # id of ship
		syscall
		add $t0, $v0, $zero #ship.x
		add $t1, $v1, $zero # ship.y
		
		#create rbomb
		la $t4, arbomb_ids
		lw $t5, 0($t4)
		addi $t2, $zero,0 #the $t2 th rbomb being checked
		
crb_loop:		addi $t6,$zero,20
		beq $t2,$t6,emit_rbomb_exit #if (checked 20 bombs) then emit_rbomb_exit
		sll $t3,$t2,2
		add $t3,$t3,$t4
		addi $t6,$zero,-1
		lw $t5,0($t3)
		bne $t5,$t6, crb_next_loop #if($t5 != -1) then find next id
		#else create rbomb with id :62 + $t2
		
		li $v0, 105 #play sound of emit bomb
		addi $a0,$zero,2
		addi $a1,$zero,0
		syscall
		
		addi $a0,$t2,62 #a0 = id of rbomb	
		sw $a0,0($t3) #store id	
		addi $a1,$t0,65	#x_loc of rbomb
		addi $a2,$t1,60 #y_loc of rbomb
		addi $a3,$zero,4 #speed of rbomb
		li $v0,107
		syscall
		
		#update amount of rbomb
		addi $s3,$s3,1
		la $t4, rbomb_count
		sw $s3,	0($t4)	
		li $v0,123
		sub $a0,$s0,$s1
		sub $a1,$s2,$s3
		syscall
		j emit_rbomb_exit
		
crb_next_loop:	addi $t2,$t2,1
		j crb_loop
		
emit_rbomb_exit:	lw $s3,8($sp)
		lw $s2,12($sp)
		lw $s1,16($sp)
		lw $s0,20($sp)
		lw $ra,24($sp)
		addi $sp, $sp, 28
		jr $ra


#--------------------------------------------------------------------
# func activate_rbombs
# Activate all the remote bombs: change their status to "activated"!
#--------------------------------------------------------------------
activate_rbombs:	addi $sp, $sp, -28
		sw $ra, 24($sp)
		sw $s0, 20($sp)
		sw $s1, 16($sp)
		sw $s2, 12($sp)
		sw $s3, 8($sp)

		la $t4, arbomb_ids
		lw $t5, 0($t4)
		addi $t2, $zero,0 #the $t2 th rbomb being checked
		
activate_loop:	addi $t6,$zero,20
		beq $t2,$t6,activate_exit #if (checked 20 bombs) then activate_exit
		sll $t3,$t2,2
		add $t3,$t3,$t4
		addi $t6,$zero,-1
		lw $t5,0($t3)
		beq $t5,$t6, activate_next_loop #if($t5 == -1) then find next id
		
		#if inactive, active it
		li $v0, 108 #get remote status
		move $a0, $t5
		syscall 
		beqz $v0,active_it
		j activate_next_loop
		
active_it:		li $v0, 109
		move $a0, $t5
		syscall
		
activate_next_loop:	addi $t2,$t2,1
		j activate_loop
		
activate_exit:	lw $s3,8($sp)
		lw $s2,12($sp)
		lw $s1,16($sp)
		lw $s0,20($sp)
		lw $ra,24($sp)
		addi $sp, $sp, 28
		jr $ra

#--------------------------------------------------------------------
# func check_intersection(rec1, rec2)
# @rec1: ((x1, y1), (x2, y2))
# @rec2: ((x3, y3), (x4, y4))
# these 8 parameters are passed through stack!
# This function is to check whether the above two rectangles are 
# intersected!
# @return 1: true; 0: false
#--------------------------------------------------------------------
check_intersection:	addi $sp, $sp, -32
		lw $s0,28($sp)	# a.top_left.x
		lw $s1,24($sp)	# a.top_left.y
		lw $s2,20($sp)	#a.bottom_right.x
		lw $s3,16($sp)	#a.bottom_right.y
		lw $s4,12($sp)	#b.top_left.x
		lw $s5,8($sp)	#b.top_left.y
		lw $s6,4($sp)	#b.bottom_right.x
		lw $s7,0($sp)	#b.bottom_right.y

		slt $t4,$s0,$s4
		beqz $t4,ci_compare_x2
		
		slt $t4,$s4,$s2
		beqz $t4,ci_no
		j ci_compare_y
		
ci_compare_x2:	slt $t4,$s0,$s6
		beqz $t4,ci_no
		j ci_compare_y
		
ci_compare_y:	slt $t4,$s1,$s5
		beqz $t4,ci_compare_y2
		
		slt $t4,$s5,$s3
		beqz $t4,ci_no
		j ci_yes
		
ci_compare_y2:	slt $t4,$s1,$s7
		beqz $t4,ci_no
		j ci_compare_y3
		
ci_compare_y3:	slt $t4,$s7,$s3
		beqz $t4,ci_no		
		j ci_yes

ci_yes:		li $v0, 1
		j ci_exit
		
ci_no: 		li $v0, 0
		
ci_exit:		
		sw $zero,28($sp)	# a.top_left.x
		sw $zero,24($sp)	# a.top_left.y
		sw $zero,20($sp)	#a.bottom_right.x
		sw $zero,16($sp)	#a.bottom_right.y
		sw $zero,12($sp)	#b.top_left.x
		sw $zero,8($sp)	#b.top_left.y
		sw $zero,4($sp)	#b.bottom_right.x
		sw $zero,0($sp)	#b.bottom_right.y
		addi $sp, $sp,32
		jr $ra

#--------------------------------------------------------------------
# func check_bomb_hits
# 1. For each simple bomb, check whether it hits any submarine
#    or dolphin.
# 2. For each remote bomb, check whether the activated one hits
#    any submarine or dolphin.
# 3. The dolphin will always hurt; but submarine depends!
# 4. update the score value! 
#--------------------------------------------------------------------
check_bomb_hits:	addi $sp, $sp, -32
		sw $ra, 28($sp)
		sw $s0, 24($sp)
		sw $s1, 20($sp)
		sw $s2, 16($sp)
		sw $s3, 12($sp)
		sw $s4, 8($sp)
		sw $s5, 4($sp)
		sw $s6, 0($sp)
		
		la $s0, abomb_ids		
		addi $s2,$zero,-1 #$s2 = no of bombs checked (first one should be 0)
		
cbh_b_loop:	addi $s2,$s2,1
		slti $s4,$s2,20
		beqz $s4, cbh_b_exit #if ($s2>=20) then cbh_b_exit
		sll $s5,$s2,2
		add $s6,$s5,$s0
		lw $s1,0($s6)#$s1 = active bomb id
		addi $s3,$zero,-1
		beq $s1,$s3,cbh_b_loop #if ($s1 = -1) then cbh_b_loop
		move $a0, $s1 #else check_one_bomb_hit 
		jal check_one_bomb_hit
		j cbh_b_loop
		
cbh_b_exit:	la $s0, arbomb_ids #after checking the bombs, check rbomb		
		addi $s2,$zero,-1 #$s2 = no of rbombs checked (first one should be 0)
		
cbh_rb_loop:	addi $s2,$s2,1
		slti $s4,$s2,20
		beqz $s4, cbh_exit #if ($s2>=20) thencbh_exit
		sll $s5,$s2,2
		add $s6,$s5,$s0
		lw $s1,0($s6)#$s1 = active rbomb id
		addi $s3,$zero,-1
		beq $s1,$s3,cbh_rb_loop #if ($s1 = -1) then cbh_rb_loop
		
		li $v0 108 #get remote status
		move $a0,$s1
		syscall
		
		beqz $v0,cbh_rb_loop
		move $a0, $s1 #else check_one_bomb_hit 
		
		jal check_one_bomb_hit
		j cbh_rb_loop
		
cbh_exit:		lw $ra, 28($sp)
		lw $s0, 24($sp)
		lw $s1, 20($sp)
		lw $s2, 16($sp)
		lw $s3, 12($sp)
		lw $s4, 8($sp)
		lw $s5, 4($sp)
		lw $s6, 0($sp)
		addi $sp, $sp, 32
		jr $ra

#--------------------------------------------------------------------
# check_one_bomb_hit:
# @a0: bomb id
# Given the bomb id, check whether it hits with any dolphin or
# submarin.
#--------------------------------------------------------------------
check_one_bomb_hit:	addi $sp, $sp, -36
			sw $ra, 32($sp)
			sw $s0, 28($sp)
			sw $s1, 24($sp)
			sw $s2, 20($sp)
			sw $s3, 16($sp)
			sw $s4, 12($sp)
			sw $s5, 8($sp)
			sw $s6, 4($sp)
			sw $s7, 0($sp)
			
			li $v0,110	#get bomb location
			move $t6,$a0	#$t6 = bomb id
			syscall
			move $t0, $v0 # $s0 = bomb_x
			move $t1, $v1 # $s1 = bomb_y
			addi $t7,$zero,0 #assume bomb not explode
			#--------------------------------------------------------------------------------------------------#
			
			la $t2, dolphin_ids
			addi $t5,$zero,0 #t5 = no of dolphin havet checked
		
			lw $t3,0($t2)# $t3 = dolpin_id
			addi $t4,$zero,-1
			beq $t3,$t4, dhit_next_loop #if (id = -1) then dhit_next_loop
dhit_loop:		li $v0, 110
			move $a0, $t3 # id of dolphins 
			syscall
			add $t8, $v0, $zero #dolphin.x
			add $t9, $v1, $zero #dolphin. y
			
			#put direction into stack
			sw $t0, -4($sp) # bomb.x1
			sw $t1, -8($sp) # bomb.y1
			add $t4, $t0, 30 # width of bomb
			sw $t4, -12($sp) # bomb.x2
			add $t4, $t1, 30 # height of bomb
			sw $t4, -16($sp) # bomb.y2
			
			sw $t8, -20($sp) # dolphin.x1
			sw $t9, -24($sp) # dolphin.y1
			add $t4, $t8, 60 # width of dolphin
			sw $t4, -28($sp) # dolphin.x2
			add $t4, $t9, 40 # height of dolphin
			sw $t4, -32($sp) # dolphin.y2
			jal check_intersection

			beqz $v0,dhit_next_loop #if(no intersect) then dhit_next_loop
			addi $t7,$zero,1 #else set bomb as bombed
			
			li $v0,105 #play hit sound
			li $a0,5
			li $a1,0
			syscall
			
			li $v0, 114 #deduct hit point of dolphin
			move $a0, $t3
			li $a1, 10
			syscall
			
dhit_next_loop:		addi $t5,$t5,1
			slti $t4,$t5,20 
			beqz $t4,dhit_exit #if (t5>=20) then exit
			sll $t4,$t5,2
			la $t2, dolphin_ids
			add $t2,$t2,$t4			
			lw $t3, 0($t2)
			addi $t4,$zero,-1
			beq $t3,$t4, dhit_next_loop #if (id = -1) then dhit_next_loop
			j dhit_loop
			
dhit_exit:	
			#--------------------------------------------------------------------------------------------------#
			
			#after check dolphine, check submarine
			#check center first
			la $t2, subma_ids
			addi $t5,$zero,0 #t5 = no of submarine havet checked
		
			lw $t3,0($t2)# $t3 = submarine_id
			addi $t4,$zero,-1
			beq $t3,$t4, sub_hit_next_loop #if (id = -1) then sub_hit_next_loop
sub_hit_loop:		li $v0, 110
			move $a0, $t3 # id of submarine
			syscall
			add $t8, $v0, $zero #submarine.x
			add $t9, $v1, $zero #submarine. y
			
			#put direction into stack
			sw $t0, -4($sp) # bomb.x1
			sw $t1, -8($sp) # bomb.y1
			add $t4, $t0, 30 # width of bomb
			sw $t4, -12($sp) # bomb.x2
			add $t4, $t1, 30 # height of bomb
			sw $t4, -16($sp) # bomb.y2
			
			add $t4, $t8, 65 # submarine.center
			sw $t4, -20($sp) # submarine.center.x1
			sw $t9, -24($sp) # submarine.y1
			add $t4, $t8, 10 # width of submarine center
			sw $t4, -28($sp) # submarine.x2
			add $t4, $t9, 40 # height of submarine
			sw $t4, -32($sp) # submarine.y2
			jal check_intersection

			beqz $v0,sub_hit #if(no intersect) then sub_hit
			addi $t7,$zero,1 #else set bomb as bombed
			
			li $v0,105 #play hit sound
			li $a0,5
			li $a1,0
			syscall
			
			li $v0,118 #get remain hit point of submarine
			move $a0, $t3
			syscall
			move $t4,$v0
			
			li $v0, 114 #deduct hit point of submarine to 0
			move $a0, $t3
			move $a1, $t4	#deduct remain hit point
			syscall
			j sub_hit_next_loop #if it hit center, no need to check other place


sub_hit:			li $v0, 110
			move $a0, $t3 # id of submarine
			syscall
			add $t8, $v0, $zero #submarine.x
			add $t9, $v1, $zero #submarine. y
			
			#put direction into stack
			sw $t0, -4($sp) # bomb.x1
			sw $t1, -8($sp) # bomb.y1
			add $t4, $t0, 30 # width of bomb
			sw $t4, -12($sp) # bomb.x2
			add $t4, $t1, 30 # height of bomb
			sw $t4, -16($sp) # bomb.y2
			
			sw $t8, -20($sp) # submarine.x1
			sw $t9, -24($sp) # submarine.y1
			add $t4, $t8, 60 # width of submarine
			sw $t4, -28($sp) # submarine.x2
			add $t4, $t9, 40 # height of submarine
			sw $t4, -32($sp) # submarine.y2
			jal check_intersection

			beqz $v0,sub_hit_next_loop #if(no intersect) then sub_next_loop
			addi $t7,$zero,1 #else set bomb as bombed
			
			li $v0,105 #play hit sound
			li $a0,5
			li $a1,0
			syscall
			
			li $v0, 114 #deduct hit point of submarine
			move $a0, $t3
			li $a1, 5
			syscall
			
sub_hit_next_loop:		addi $t5,$t5,1
			slti $t4,$t5,20 
			beqz $t4,sub_hit_exit #if (t5>=20) then exit
			sll $t4,$t5,2
			la $t2, subma_ids
			add $t2,$t2,$t4			
			lw $t3, 0($t2)
			addi $t4,$zero,-1
			beq $t3,$t4, sub_hit_next_loop #if (id = -1) then sub_hit_next_loop
			j sub_hit_loop
			
sub_hit_exit:				
			
			#--------------------------------------------------------------------------------------------------#
			#if ($t7 = 1) destroy bomb after checking all interaction
			beqz $t7,check_one_bomb_hit_exit
			
			li $v0, 105 #play explode sound
			li $a0, 1
			li $a1, 0
			syscall
			
			li $v0, 114 #deduct hit point of bomb
			move $a0, $t6
			li $a1, 1
			syscall
			
check_one_bomb_hit_exit:	lw $ra, 32($sp)
			lw $s0, 28($sp)
			lw $s1, 24($sp)
			lw $s2, 20($sp)
			lw $s3, 16($sp)
			lw $s4, 12($sp)
			lw $s5, 8($sp)
			lw $s6, 4($sp)
			lw $s7, 0($sp)
			addi $sp, $sp, 36
			jr $ra

#--------------------------------------------------------------------
# func: update_score
# The score will be collected from submarines.
#--------------------------------------------------------------------
update_score:	add $sp, $sp, -24
		sw $ra, 20($sp)
		sw $s0, 16($sp)
		sw $s1, 12($sp)
		sw $s2, 8($sp)
		sw $s3, 4($sp)
		sw $s4, 0($sp)
		
		la $s0,subma_num
		lw $s1,0($s0) #$s1 = original subma_no
		addi $t0,$zero,0 #$t0 = sumba remain

		la $t2, subma_ids
		addi $t5,$zero,0 #t5 = no of submarine have checked
		
		addi $t8,$zero,0 #t8 = cumulate score
		
		lw $t3,0($t2)# $t3 = subma_id
		addi $t4,$zero,-1
		beq $t3,$t4, us_next_loop #if (id = -1) then us_next_loop

us_loop:		addi $t0,$t0,1
		li $v0, 115 #get object score
		move $a0, $t3 # id of submarine
		syscall
		add $t8, $t8, $v0 #submarine.hit_point
			
us_next_loop:	addi $t5,$t5,1
		slti $t4,$t5,20 
		beqz $t4,us_exit #if (t5>=20) then exit
		sll $t4,$t5,2
		la $t2, subma_ids
		add $t2,$t2,$t4			
		lw $t3, 0($t2)
		addi $t4,$zero,-1
		beq $t3,$t4, us_next_loop #if (id = -1) then us_next_loop
		j us_loop
			
us_exit:		sub $s2,$s1,$t0 #$s2 = subma destroyed
		sll $s3,$s2,4 #16 marks
		sll $s4,$s2,2 #4 marks
		add $t8,$t8,$s3
		add $t8,$t8,$s4 #total 20 marks for each destroyed dubmarine
		li $v0, 117 #update game score
		move $a0,$t8
		syscall
		
		lw $ra, 20($sp)
		lw $s0, 16($sp)
		lw $s1, 12($sp)
		lw $s2, 8($sp)
		lw $s3, 4($sp)
		lw $s4, 0($sp)
		add $sp, $sp, 24
		jr $ra

#--------------------------------------------------------------------
# func: check_game_end
# Check whether the game is over!
#The player wins the game, only when all the submarines are destroyed and at least one dolphin survives. 
#Otherwise, the player loses the game.
# $v0=0: not end; =1: win; =2: lose
#--------------------------------------------------------------------
check_game_end:		addi $sp, $sp, -12
			sw $ra, 8($sp)
			sw $s0, 4($sp)
			sw $s1, 0($sp)
			
			addi $v0,$zero,0 #assume continue
			
			la $t2, dolphin_ids
			addi $t5,$zero,-1 #t5 = no of dolphin checked (first be 0)
			
d_cge_loop:		addi $t5,$t5,1
			slti $t4,$t5,20 
			beqz $t4,check_game_end_lose #if (t5>=20) then lose (no dolphin)
			sll $t1,$t5,2
			add $t0,$t2,$t1
			lw $t3, 0($t0)
			beq $t3,$t6, d_cge_loop #if (id = -1) then d_cge_loop
			j s_cge #dolphin exist, check submarine
			
s_cge:			la $t2, subma_ids
			addi $t5,$zero,-1 #t5 = no of submarine checked (first be 0)
			
s_cge_loop:		addi $t5,$t5,1
			slti $t4,$t5,20 
			beqz $t4,check_game_end_win #if (t5>=20) then win (no submarine)
			sll $t1,$t5,2
			add $t0,$t2,$t1
			lw $t3, 0($t0)
			beq $t3,$t6, s_cge_loop #if (id = -1) then s_cge_loop
			j check_game_end_exit #submarine exist, continue

check_game_end_win:	addi $v0,$zero,1
			j check_game_end_exit
	
check_game_end_lose:	addi $v0,$zero,2
			j check_game_end_exit
		
check_game_end_exit:	lw $s1,0($sp)
			lw $s0,4($sp)
			lw $ra, 8($sp)
			addi $sp, $sp, 12
			jr $ra
	
#--------------------------------------------------------------------
# func: move_ship
# Move the ship by one step, determined by its speed and direction.
# If the ship is going to cross the boarder, opposite the direction and
# set its location appropriately!
# Eg:=> if x_od + speed > 640; then x_new = 1276 - x_old;
#    <= if x_old - speed < 0; then x_new = 4 - x_old;
# also change the direction
#--------------------------------------------------------------------
move_ship:	addi $sp, $sp, -12
		sw $ra, 8($sp)
		sw $s0, 4($sp)
		sw $s1, 0($sp)
		li $v0, 110
		li $a0, 1 # id of ship
		syscall
		add $s0, $v0, $zero #xold
		add $s1, $v1, $zero # y
		li $v0, 112 # get direction
		li $a0, 1
		syscall
		add $t0, $v0, $zero
		beq $t0, $zero, ms_left # direction: left; check left border
		# the ship speed is 4, and heads right
		addi $t0, $zero, 636
		slt $t1, $t0, $s0
		bne $t1, $zero, ms_lt
		li $v0, 121 # no need to turn direction, move one step
		li $a0, 1
		syscall 
		j ms_exit
ms_lt: 	 	li $t0, 1276 # turns left
		sub $a1, $t0, $s0
		add $a2, $s1, $zero
		li $v0, 120 # set object location
		li $a0, 1
		syscall
		li $v0, 113
		li $a1, 0 # turn left
		li $a0, 1
		syscall 
		j ms_exit
ms_left:		slti $t0, $s0, 4
		bne $t0, $zero, ms_rt
		li $v0, 121 # no need to turn direction, move one step
		li $a0, 1
		syscall
		j ms_exit
ms_rt:		li $a0, 1 # turn right
		li $t0, 4
		sub $a1, $t0, $s0
		add $a2, $s1, $zero
		li $v0, 120
		syscall
		li $v0, 113
		li $a1, 1 # turn right
		li $a0, 1
		syscall
ms_exit:	lw $ra, 8($sp)
		lw $s0, 4($sp)
		lw $s1, 0($sp)
		addi $sp, $sp, 12
		jr $ra

		
#--------------------------------------------------------------------
# func: move_dolphins
# If a dolphin is going to cross the boarder, opposite the direction and
# set its location appropriately!
# Eg:=> if x_old +speed >= 740, then x_new = 1475 - x_old; 
#    <= if x_old - speed < 0; then x_new = 5 - x_old;
# also change the direction
#--------------------------------------------------------------------	
move_dolphins:	addi $sp, $sp, -12
		sw $ra, 8($sp)
		sw $s0, 4($sp)
		sw $s1, 0($sp)
		
		la $t2, dolphin_ids
		addi $t5,$zero,20 #t5 = no of dolphin not yet checked
		
		lw $t3,0($t2)
		addi $t6,$zero,-1
md_loop:		beq $t3,$t6, md_next_loop #if (id = -1) then md_next_loop
		li $v0, 110
		move $a0, $t3 # id of dolphins 
		syscall
		add $s0, $v0, $zero #xold
		add $s1, $v1, $zero # y
		li $v0, 112 # get direction
		move $a0, $t3
		syscall
		add $t0, $v0, $zero
		beq $t0, $zero, md_left # direction: left; check left border
		# the dolphins  speed is 5, and heads right
		addi $t0, $zero, 735
		slt $t1, $t0, $s0
		bne $t1, $zero, md_lt
		li $v0, 121 # no need to turn direction, move one step
		move $a0, $t3
		syscall 
		j md_next_loop
		
md_lt: 	 	li $t0, 1475 # turns left
		sub $a1, $t0, $s0
		add $a2, $s1, $zero
		li $v0, 120 # set object location
		move $a0, $t3
		syscall
		li $v0, 113
		li $a1, 0 # turn left
		move $a0, $t3
		syscall 
		j md_next_loop
		
md_left:		slti $t0, $s0, 5
		bne $t0, $zero, md_rt
		li $v0, 121 # no need to turn direction, move one step
		move $a0, $t3
		syscall
		j md_next_loop
		
md_rt:		move $a0, $t3 # turn right   
		li $t0, 5
		sub $a1, $t0, $s0
		add $a2, $s1, $zero
		li $v0, 120
		syscall
		li $v0, 113
		li $a1, 1 # turn right
		move $a0, $t3
		syscall
		
md_next_loop:	addi $t5,$t5,-1
		slti $t4,$t5,1 
		bnez $t4,md_exit #if (t5<1) then exit
		addi $t2,$t2,4
		lw $t3, 0($t2)
		beq $t3,$t6, md_next_loop #if (id = -1) then md_next_loop
		j md_loop
		
md_exit:		lw $ra, 8($sp)
		lw $s0, 4($sp)
		lw $s1, 0($sp)
		addi $sp, $sp, 12
		jr $ra
		
#--------------------------------------------------------------------
# func: move_submarines
# If a submarine is going to cross the boarder, opposite the direction and
# set its location appropriately!
# Eg:=> if x_old +speed >= 720, then x_new = 1434 - x_old; 
#    <= if x_old - speed < 0; then x_new = 6 - x_old;
# also change the direction
#--------------------------------------------------------------------	
move_submarines:	addi $sp, $sp, -12
		sw $ra, 8($sp)
		sw $s0, 4($sp)
		sw $s1, 0($sp)
		
		la $t2, subma_ids
		addi $t5,$zero,20 #t5 = no of submarines not yet checked
		
		lw $t3, 0($t2)#load id array into $t3
		addi $t6,$zero,-1
msu_loop:	beq $t3,$t6, msu_next_loop #if (id = -1) then msu_next_loop
		li $v0, 110
		move $a0, $t3 # id of submarines
		syscall
		add $s0, $v0, $zero #xold
		add $s1, $v1, $zero # y
		li $v0, 112 # get direction
		move $a0, $t3
		syscall
		add $t0, $v0, $zero
		beq $t0, $zero, msu_left # direction: left; check left border
		# the submarines  speed is 6, and heads right
		addi $t0, $zero, 712
		slt $t1, $t0, $s0
		bne $t1, $zero, msu_lt
		li $v0, 121 # no need to turn direction, move one step
		move $a0, $t3
		syscall 
		j msu_next_loop
		
msu_lt: 	 	li $t0, 1433 # turns left
		sub $a1, $t0, $s0
		add $a2, $s1, $zero
		li $v0, 120 # set object location
		move $a0, $t3
		syscall
		li $v0, 113
		li $a1, 0 # turn left
		move $a0, $t3
		syscall 
		j msu_next_loop
		
msu_left:		slti $t0, $s0, 6
		bne $t0, $zero, msu_rt
		li $v0, 121 # no need to turn direction, move one step
		move $a0, $t3
		syscall
		j msu_next_loop
		
msu_rt:		move $a0, $t3 # turn right   
		li $t0, 6
		sub $a1, $t0, $s0
		add $a2, $s1, $zero
		li $v0, 120
		syscall
		li $v0, 113
		li $a1, 1 # turn right
		move $a0, $t3
		syscall
		
msu_next_loop:	addi $t5,$t5,-1
		slti $t4,$t5,1 
		bnez $t4,msu_exit #if (t5<1) then exit
		addi $t2,$t2,4
		lw $t3, 0($t2)
		beq $t3,$t6, msu_next_loop #if (id = -1) then msu_next_loop
		j msu_loop
		
msu_exit:		lw $ra, 8($sp)
		lw $s0, 4($sp)
		lw $s1, 0($sp)
		addi $sp, $sp, 12
		jr $ra

	
#--------------------------------------------------------------------
# func: move_bombs
# If a bomb is going to cross the bottom, destroy the bomb and
# increase the available number of boms.
# Eg:=> if y_old + speed >= 600, then destory it;
#--------------------------------------------------------------------
move_bombs:	addi $sp, $sp, -12
		sw $ra, 8($sp)
		sw $s0, 4($sp)
		sw $s1, 0($sp)
		
		la $t2, abomb_ids
		add $t5,$zero,20 #t5 = no of bombs not yet checked
		addi $t6,$zero,-1
		
		lw $t3, 0($t2)#load id array into $t3		
		beq $t3,$t6, mb_next_loop #if (id = -1) then mb_next_loop
mb_loop:		li $v0, 110
		move $a0, $t3 # id of bombs
		syscall
		add $s0, $v0, $zero #xold
		add $s1, $v1, $zero # y
		
		# the bombs  speed is 4, and heads down
		addi $t0, $zero, 564
		slt $t1, $t0, $s1
		bne $t1, $zero, mb_destroy
		li $v0, 121 #inbound, move one step
		move $a0, $t3
		syscall 
		j mb_next_loop
		
mb_destroy: 	li $v0, 116 # destroy the object
		move $a0, $t3
		syscall
		
		#load bomb counter info
		la $t4, rbomb_num
		lw $s2,0($t4)
		la $t4, rbomb_count
		lw $s3,0($t4)
		la $t4, bomb_num
		lw $s0,0($t4)
		la $t4, bomb_count
		lw $s1,0($t4)
		
		addi $s1,$s1,-1 #update bomb counter
		la $t4, bomb_count
		sw $s1,0($t4)
		
		la $t7,abomb_ids #delete id from active bomb array
		addi $t8,$zero,20
		sub $t9,$t8,$t5
		sll $t9,$t9,2
		add $t7,$t7,$t9
		sw $t6,0($t7)
		
		li $v0,123 #update bomb numbers
		sub $a0,$s0,$s1
		sub $a1,$s2,$s3
		syscall
		
mb_next_loop:	addi $t5,$t5,-1
		slti $t4,$t5,1 
		bnez $t4,mb_exit #if (t5<1) then exit
		addi $t2,$t2,4
		lw $t3, 0($t2)
		beq $t3,$t6, mb_next_loop #if (id = -1) then mb_next_loop
		j mb_loop
		
mb_exit:		lw $ra, 8($sp)
		lw $s0, 4($sp)
		lw $s1, 0($sp)
		addi $sp, $sp, 12
		jr $ra
#---------------------------------------------------------------------------------------------------------------------------------------------------#
move_rbombs:	addi $sp, $sp, -12
		sw $ra, 8($sp)
		sw $s0, 4($sp)
		sw $s1, 0($sp)
		
		la $t2, arbomb_ids
		add $t5,$zero,20 #t5 = no of rbombs not yet checked
		addi $t6,$zero,-1
		
		lw $t3, 0($t2)#load id array into $t3		
		beq $t3,$t6, mrb_next_loop #if (id = -1) then mrb_next_loop
mrb_loop:	li $v0, 110 #get location
		move $a0, $t3 # id of rbombs
		syscall
		add $s0, $v0, $zero #xold
		add $s1, $v1, $zero # y
		
		# the rbombs  speed is 4, and heads down
		addi $t0, $zero, 564
		slt $t1, $t0, $s1
		bne $t1, $zero, mrb_destroy
		li $v0, 121 #inbound, move one step
		move $a0, $t3
		syscall 
		j mrb_next_loop
		
mrb_destroy: 	li $v0, 116 # destroy the object
		move $a0, $t3
		syscall
		
		#load bomb counter info
		la $t4, rbomb_num
		lw $s2,0($t4)
		la $t4, rbomb_count
		lw $s3,0($t4)
		la $t4, bomb_num
		lw $s0,0($t4)
		la $t4, bomb_count
		lw $s1,0($t4)
		
		addi $s3,$s3,-1 #update rbomb counter
		la $t4, rbomb_count
		sw $s3,0($t4)
		
		la $t7,arbomb_ids #delete id from active rbomb array
		addi $t8,$zero,20
		sub $t9,$t8,$t5
		sll $t9,$t9,2
		add $t7,$t7,$t9
		sw $t6,0($t7)
		
		li $v0,123 #update bomb numbers
		sub $a0,$s0,$s1
		sub $a1,$s2,$s3
		syscall
		
mrb_next_loop:	addi $t5,$t5,-1
		slti $t4,$t5,1 
		bnez $t4,mrb_exit #if (t5<1) then exit
		addi $t2,$t2,4
		lw $t3, 0($t2)
		beq $t3,$t6, mrb_next_loop #if (id = -1) then mrb_next_loop
		j mrb_loop
		
mrb_exit:		lw $ra, 8($sp)
		lw $s0, 4($sp)
		lw $s1, 0($sp)
		addi $sp, $sp, 12
		jr $ra
#--------------------------------------------------------------------
# func update_object_status
# 1. if the dolphin is dead, then destroy the game object;
# 2. if the submarine is destroyed, then destroy the game object;
# 3. if the (r)bomb is already bombed, then destroy the game object;
#--------------------------------------------------------------------

update_object_status: 	addi $sp, $sp, -20
			sw $ra, 0($sp)
			sw $s0, 4($sp)
			sw $s1, 8($sp)
			sw $s2, 12($sp)
			sw $s3, 16($sp)
			#assume hit_point >=0
#-----------------------------------------------------------------------------------------------------------------------------#
			#dolphin
			la $t2, dolphin_ids
			addi $t5,$zero,0 #t5 = no of dolphin have checked
		
			lw $t3,0($t2)# $t3 = dolpin_id
			addi $t4,$zero,-1
			beq $t3,$t4, duos_next_loop #if (id = -1) then duos_next_loop

duos_loop:		li $v0, 118 #get hit point
			move $a0, $t3 # id of dolphins 
			syscall
			add $t8, $v0, $zero #dolphin.hit_point
			bnez $t8,duos_next_loop #if (hit point != 0) then duos_next_loop
			#elese duos_del
			
duos_del:			li $v0, 116 #destroy object
			move $a0, $t3 # id of dolphins 
			syscall
			
			addi $t1,$zero,-1
			sw $t1,0($t2) #update the id array
			
duos_next_loop:		addi $t5,$t5,1
			slti $t4,$t5,20 
			beqz $t4,duos_exit #if (t5>=20) then exit
			sll $t4,$t5,2
			la $t2, dolphin_ids
			add $t2,$t2,$t4			
			lw $t3, 0($t2)
			addi $t4,$zero,-1
			beq $t3,$t4, duos_next_loop #if (id = -1) then duos_next_loop
			j duos_loop
			
duos_exit:		#after checking dolphin, check submarine
#-----------------------------------------------------------------------------------------------------------------------------#
			#submarine
			la $t2, subma_ids
			addi $t5,$zero,0 #t5 = no of submarine have checked
		
			lw $t3,0($t2)# $t3 = subma_id
			addi $t4,$zero,-1
			beq $t3,$t4, suos_next_loop #if (id = -1) then suos_next_loop

suos_loop:		li $v0, 118 #get hit point
			move $a0, $t3 # id of submarine
			syscall
			add $t8, $v0, $zero #submarine.hit_point
			bnez $t8,suos_next_loop #if (hit point != 0) then suos_next_loop
			#elese suos_del
			
suos_del:			li $v0, 116 #destroy object
			move $a0, $t3 # id of submarine
			syscall
			
			addi $t1,$zero,-1
			sw $t1,0($t2) #update the id array
			
suos_next_loop:		addi $t5,$t5,1
			slti $t4,$t5,20 
			beqz $t4,suos_exit #if (t5>=20) then exit
			sll $t4,$t5,2
			la $t2, subma_ids
			add $t2,$t2,$t4			
			lw $t3, 0($t2)
			addi $t4,$zero,-1
			beq $t3,$t4, suos_next_loop #if (id = -1) then suos_next_loop
			j suos_loop
			
suos_exit:			#after checking submarin, check bomb
#-----------------------------------------------------------------------------------------------------------------------------#
			#simple bomb
			la $t2, abomb_ids
			addi $t5,$zero,0 #t5 = no of bomb have checked
		
			lw $t3,0($t2)# $t3 = abomb_id
			addi $t4,$zero,-1
			beq $t3,$t4, buos_next_loop #if (id = -1) then buos_next_loop

buos_loop:		li $v0, 118 #get hit point
			move $a0, $t3 # id of bomb
			syscall
			add $t8, $v0, $zero #bomb.hit_point
			bnez $t8,buos_next_loop #if (hit point != 0) then buos_next_loop
			#elese buos_del
			
buos_del:			li $v0, 116 #destroy object
			move $a0, $t3 # id of bomb
			syscall
			
			addi $t1,$zero,-1
			sw $t1,0($t2) #update the id array
			
			#load bomb counter info
			la $t4, rbomb_num
			lw $s2,0($t4)
			la $t4, rbomb_count
			lw $s3,0($t4)
			la $t4, bomb_num
			lw $s0,0($t4)
			la $t4, bomb_count
			lw $s1,0($t4)
		
			addi $s1,$s1,-1 #update bomb counter
			la $t4, bomb_count
			sw $s1,0($t4)
		
			li $v0,123 #update bomb numbers
			sub $a0,$s0,$s1
			sub $a1,$s2,$s3
			syscall
			
buos_next_loop:		addi $t5,$t5,1
			slti $t4,$t5,20 
			beqz $t4,buos_exit #if (t5>=20) then exit
			sll $t4,$t5,2
			la $t2, abomb_ids
			add $t2,$t2,$t4			
			lw $t3, 0($t2)
			addi $t4,$zero,-1
			beq $t3,$t4, buos_next_loop #if (id = -1) then buos_next_loop
			j buos_loop
			
buos_exit:		#after checking bomb, check rbomb
#-----------------------------------------------------------------------------------------------------------------------------#
			#remote bomb
			la $t2, arbomb_ids
			addi $t5,$zero,0 #t5 = no of rbomb have checked
		
			lw $t3,0($t2)# $t3 = arbomb_id
			addi $t4,$zero,-1
			beq $t3,$t4, rbuos_next_loop #if (id = -1) then rbuos_next_loop

rbuos_loop:		li $v0, 118 #get hit point
			move $a0, $t3 # id of rbomb
			syscall
			add $t8, $v0, $zero #rbomb.hit_point
			bnez $t8,rbuos_next_loop #if (hit point != 0) then rbuos_next_loop
			#elese rbuos_del
			
rbuos_del:		li $v0, 116 #destroy object
			move $a0, $t3 # id of rbomb
			syscall
			
			addi $t1,$zero,-1
			sw $t1,0($t2) #update the id array
			
			#load bomb counter info
			la $t4, rbomb_num
			lw $s2,0($t4)
			la $t4, rbomb_count
			lw $s3,0($t4)
			la $t4, bomb_num
			lw $s0,0($t4)
			la $t4, bomb_count
			lw $s1,0($t4)
		
			addi $s3,$s3,-1 #update rbomb counter
			la $t4, rbomb_count
			sw $s3,0($t4)
		
			li $v0,123 #update bomb numbers
			sub $a0,$s0,$s1
			sub $a1,$s2,$s3
			syscall
			
rbuos_next_loop:		addi $t5,$t5,1
			slti $t4,$t5,20 
			beqz $t4,rbuos_exit #if (t5>=20) then exit
			sll $t4,$t5,2
			la $t2, arbomb_ids
			add $t2,$t2,$t4			
			lw $t3, 0($t2)
			addi $t4,$zero,-1
			beq $t3,$t4, rbuos_next_loop #if (id = -1) then rbuos_next_loop
			j rbuos_loop
			
rbuos_exit:		#after checking rbomb,all done		
			li $v0, 119 # refresh screen
			syscall 
#-----------------------------------------------------------------------------------------------------------------------------#

 			lw $ra, 0($sp)
			lw $s0, 4($sp)
			lw $s1, 8($sp)
			lw $s2, 12($sp)
			lw $s3, 16($sp)
			addi $sp, $sp, 20
			jr $ra
#--------------------------------------------------------------------
# func: get_time
# Get the current time
# $v0 = current time
#--------------------------------------------------------------------
get_time:	li $v0, 30
		syscall # this syscall also changes the value of $a1
		andi $v0, $a0, 0x3FFFFFFF # truncated to milliseconds from some years ago
		jr $ra

#--------------------------------------------------------------------
# func: have_a_nap(last_iteration_time, nap_time)
#--------------------------------------------------------------------
have_a_nap:
	addi $sp, $sp, -8
	sw $ra, 4($sp)
	sw $s0, 0($sp)
	add $s0, $a0, $a1
	jal get_time
	sub $a0, $s0, $v0
	slt $t0, $zero, $a0 
	bne $t0, $zero, han_p
	li $a0, 1 # sleep for at least 1ms
han_p:	li $v0, 32 # syscall: let mars java thread sleep $a0 milliseconds
	syscall
	lw $ra, 4($sp)
	lw $s0, 0($sp)
	addi $sp, $sp, 8
	jr $ra
	
#--------------------------------------------------------------------
# func get_keyboard_input
# $v0: ASCII value of the input character if input is available;
#      otherwise, the value is 0;
#--------------------------------------------------------------------
get_keyboard_input:
		addi $sp, $sp, -4
		sw $ra, 0($sp)
		add $v0, $zero, $zero
		lui $a0, 0xFFFF
		lw $a1, 0($a0)
		andi $a1, $a1, 1
		beq $a1, $zero, gki_exit
		lw $v0, 4($a0)
gki_exit:		lw $ra, 0($sp)
		addi $sp, $sp, 4
		jr $ra
