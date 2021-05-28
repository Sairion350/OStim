import discord
import sys
import os

# args: > python script.py (Discord token) (discord channel) (build name)

uploadfile = os.getcwd() + '/dist/' + sys.argv[3]

client = discord.Client()


channelID = sys.argv[2]
discordtoken = sys.argv[1]

@client.event
async def on_ready():
	print('Logged in as')
	print(client.user.name)
	print('------')
    
	area=client.get_channel(channelID)
	await area.send(file=discord.File(uploadfile, filename=sys.argv[3]))

	await client.close()



client.run(discordtoken)


