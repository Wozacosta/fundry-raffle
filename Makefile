-include .env

# those are targets, reserve those keywords 
.PHONE: all test deploy
	
# first target, :/ makes it a target
build :; forge build