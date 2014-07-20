.data
title: 		.asciiz "COMP2611 Game"
game_win:	.asciiz "You Win! Enjoy the game brought by COMP2611!"
game_lose:	.asciiz "Come on! It's an easy game!"
input_dolphin:	.asciiz "Enter the number of Dolphins: "
input_subma:	.asciiz "Enter the number of Submarines: "
input_bombs:	.asciiz "Enter the number of Simple Bombs: "
input_rbombs:	.asciiz "Enter the number of Remote Bombs: "
width:		.word 800 # the width of the screen
height:		.word 600 # the height of the screen
subma_ids:	.word -1:50 # used to keep track of the ids of submarines
subma_locs:	.word -1:100 # the array of initialized locations of submarines
subma_base:	.word 2 # base id of sumbarine
subma_num: 	.word 0 # the number of submarines
dolphin_ids:	.word -1:50 # used to keep track of the ids of dolphins
dolphin_locs:	.word -1:100 # the array of initialized locations of dolphins
dolphin_base:	.word 20 # base id of dolphin
dolphin_num: 	.word 0 # the number of dolphins
bomb_ids: 	.word -1:10 # used to keep track of the ids of bombs
bomb_base:	.word 50 # base id of the simple bomb
bomb_num:	.word 0 # the number of simple bombs
bomb_count:	.word 0 # the "running" number of simple bombs
rbomb_ids:	.word -1:10 # used to keep track of the ids of remote bombs
rbomb_base:	.word 80 # base id of the remote bomb
rbomb_num:	.word 0 # the number of remote bombs
rbomb_count:	.word 0 # the "running" number of remote bombs

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
input_game_params:
		addi $sp, $sp, -4
		sw $ra, 0($sp)
		la $a0, input_dolphin
		li $v0, 4
		syscall # print string
		li $v0, 5
		syscall # read integer
		sw $v0, 16($sp) # store number of dolphins
		la $a0, input_subma
		li $v0, 4
		syscall
		li $v0, 5
		syscall
		sw $v0, 12($sp) # store number of submarines
		la $a0, input_bombs
		li $v0, 4
		syscall
		li $v0, 5
		syscall
		sw $v0, 8($sp) # store number of simple bombs
		la $a0, input_rbombs
		li $v0, 4
		syscall
		li $v0, 5
		syscall
		sw $v0, 4($sp) # store the number of remote bombs
igp_exit:	lw $ra, 0($sp)
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



#--------------------------------------------------------------------
# func emit_one_rbomb
# 1. check whether there are avaiable remote bombs to use.
# 2. if yes, create one remote bomb object
#--------------------------------------------------------------------



#--------------------------------------------------------------------
# func activate_rbombs
# Activate all the remote bombs: change their status to "activated"!
#--------------------------------------------------------------------



#--------------------------------------------------------------------
# func check_intersection(rec1, rec2)
# @rec1: ((x1, y1), (x2, y2))
# @rec2: ((x3, y3), (x4, y4))
# these 8 parameters are passed through stack!
# This function is to check whether the above two rectangles are 
# intersected!
# @return 1: true; 0: false
#--------------------------------------------------------------------




#--------------------------------------------------------------------
# func check_bomb_hits
# 1. For each simple bomb, check whether it hits any submarine
#    or dolphin.
# 2. For each remote bomb, check whether the activated one hits
#    any submarine or dolphin.
# 3. The dolphin will always hurt; but submarine depends!
# 4. update the score value! 
#--------------------------------------------------------------------




#--------------------------------------------------------------------
# check_one_bomb_hit:
# @a0: bomb id
# Given the bomb id, check whether it hits with any dolphin or
# submarin.
#--------------------------------------------------------------------





#--------------------------------------------------------------------
# func: update_score
# The score will be collected from submarines.
#--------------------------------------------------------------------




#--------------------------------------------------------------------
# func: check_game_end
# Check whether the game is over!
# $v0=0: not end; =1: win; =2: lose
#--------------------------------------------------------------------



	
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
ms_left:	slti $t0, $s0, 4
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


		
#--------------------------------------------------------------------
# func: move_submarines
# If a submarine is going to cross the boarder, opposite the direction and
# set its location appropriately!
# Eg:=> if x_old +speed >= 720, then x_new = 1434 - x_old; 
#    <= if x_old - speed < 0; then x_new = 6 - x_old;
# also change the direction
#--------------------------------------------------------------------	


	
#--------------------------------------------------------------------
# func: move_bombs
# If a bomb is going to cross the bottom, destroy the bomb and
# increase the available number of boms.
# Eg:=> if y_old + speed >= 600, then destory it;
#--------------------------------------------------------------------




#--------------------------------------------------------------------
# func update_object_status
# 1. if the dolphin is dead, then destroy the game object;
# 2. if the submarine is destroyed, then destroy the game object;
# 3. if the (r)bomb is already bombed, then destroy the game object;
#--------------------------------------------------------------------





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
gki_exit:	lw $ra, 0($sp)
		addi $sp, $sp, 4
		jr $ra
