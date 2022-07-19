from discord_webhook import DiscordWebhook, DiscordEmbed
import os, sys
webhook = DiscordWebhook(url="https://discord.com/api/webhooks/826453992950857765/szWjSoduFI-m4x3aFPo2kHGmC5oxHpwy-WFE1Z6AwZJbkZoZgr2Myd8fc11yU1LAk0As")

#webhook.set_content("webhook content test")

#C:\\Users\\arthu\\Desktop\\mpv-shot0020.jpg

def send_webhook(file, name, ep, timestamp):
	with open(file, "rb") as f:
		webhook.add_file(file=f.read(), filename="test.jpg")
		print(os.path.basename(file))
	embed = DiscordEmbed()
	embed.set_footer(text=name + ", Episode " + ep + "\t " + timestamp)
	webhook.add_embed(embed)
	webhook.execute()

if __name__ == '__main__':
	send_webhook(sys.argv[1], sys.argv[2], sys.argv[3], sys.argv[4])