extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Engine.max_fps = 12
	if Global.session.has("fine_dreampos"):
		%Aye.position = Global.session.fine_dreampos
	else:
		Global.session.fine_dreampos = %Aye.position
	if not Global.session.has("fine_wisdom"):
		Global.session.fine_wisdom = 1
	if Global.session.fine_wisdom < 2:
		var k = 1
		for fish in $Fishes.get_children():
			fish.position.x += 1024 * k
			k *= -1
	wisdom(Global.session.fine_wisdom)


func wait(sec = 1):
	return get_tree().create_timer(sec).timeout


func wisdom(n):
	await wait(4)
	match n:
		1:
			await wait(10)
			await %Dialog.say("Hello..?")

		2:
			await wait(8)
			await %Dialog.say("So...")
			await %Dialog.say("This is your life..?")

		3:
			await wait(4)
			await %Dialog.say("Is this really how you want to live..?")
			await %Dialog.say("Is this how you want to die..?")
			await wait(4)
			await %Dialog.say("You're alive, but you're not living..")

		4:
			await wait(2)
			await %Dialog.say("What are you waiting for..?")
			await %Dialog.say("Your life to be over..?")
			await wait(4)
			await %Dialog.say("There's nothing to wait for..")
			await %Dialog.say("Death will come anyway..")

		5:
			await wait(1)
			await %Dialog.say("You're still waiting..?")
			await wait(4)
			await %Dialog.say("Why..?")
			await wait(4)
			await %Dialog.say("Is this all you're worth..?")
			await wait(4)
			await %Dialog.say("The world doesn't define your worth..")
			await %Dialog.say("Only you can decide..")

		6:
			await %Dialog.say("I know the world can be a scary place..")
			await %Dialog.say("It's okay..")
			await wait(4)
			await %Dialog.say("I know you feel that you're not good enough..")
			await %Dialog.say("But I believe in you..")
			await wait(4)
			await %Dialog.say("I know you think that you're just going to fail..")
			await %Dialog.say("And you'd be right..")
			await wait(4)

		7:
			await %Dialog.say("Are you afraid of failing..?")
			await %Dialog.say("Afraid or not.. You WILL fail..")
			await wait(4)
			await %Dialog.say("Are you afraid of loosing..?")
			await %Dialog.say("Win or lose.. You will still fail..")
			await wait(4)
			await %Dialog.say("You don't lose by failing..")
			await %Dialog.say("You lose by quitting..")
			await wait(4)
			await %Dialog.say("Do whatever you want.. just don't quit..")

		8:
			await %Dialog.say("Quitting already..?")
			await %Dialog.say("I told you you'd fail..")
			await wait(4)
			await %Dialog.say("But it's better to fail than never try..")
			await wait(4)
			await %Dialog.say("Now try again..")
			await wait(4)
			await %Dialog.say("try again..")
			await wait(4)
			await %Dialog.say("and again..!")
			await wait(4)
			await %Dialog.say("AGAIN..!!")
			await wait(4)
			await %Dialog.say("ONE MORE TIME..!!!")

		9:
			await %Dialog.say("Back for more pain..?")
			await wait(4)
			await %Dialog.say("Am I being too hard on you..?")
			await %Dialog.say("Did I expect too much..?")
			await wait(4)
			await %Dialog.say("What did YOU expect..?")
			await wait(4)
			await %Dialog.say("Don't expect to succeed..")
			await %Dialog.say("Expect only to progress..!")
			await wait(4)
			await %Dialog.say("If you can't run, then walk..")
			await %Dialog.say("If you can't walk, then crawl..")
			await %Dialog.say("No need to go fast.. Only forward..")

		10:
			await wait(8)
			await %Dialog.say("...what..?")
			await wait(16)
			await %Dialog.say("What more do you want from me..?")
			await wait(32)
			await %Dialog.say("I already told you everything you need to know..")
			await wait(64)
			await %Dialog.say("I guess there is one more thing...")
			await wait(128)
			await %Dialog.say("Call your friends..")
			await wait(256)
			await %Dialog.say("Your friends will help you..")
			await wait(512)
			await %Dialog.say("You deserve to be loved..")
			await wait(1024)
			await %Dialog.say("No.. I can't be your friend..")
			await %Dialog.say("I'm just a computer game..")
			await wait(2048)
			await %Dialog.say("You can do it..")
			await wait(4096)
			await %Dialog.say("Just go...")
			await wait(4096 * 2)
			await %Dialog.say("...")
	if n < 10:
		await wait(4)
		Global.replace_scene("bedroom", true)
		Global.session.fine_dreampos = %Aye.position
