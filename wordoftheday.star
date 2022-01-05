load("render.star", "render")
load("http.star", "http")
load("encoding/base64.star", "base64")
load("cache.star", "cache")
load("encoding/json.star", "json")

WORDNIK_ICON=base64.decode("iVBORw0KGgoAAAANSUhEUgAAAEAAAAARCAYAAABtu6qMAAAAAXNSR0IArs4c6QAABVZJREFUWEftV2lIlWkUfu71XnctzRRyzLxo/ZEgJ3PDDRvBwo0SrRQdmhokMNtA0QlyJEUZxUxt8odWIopOyx+JBomWURiYMWUwYtQWcMHcsKtXu977Dc+JGzaj1syPIWZ64YNved/znvOc5zzn/VQAFPyPh+oTAB8ZA6ysrBAQEIDi4mIcOnQIU1NTMJvNq3I0ISEBBQUFcnl6euLAgQPIysrC2NjYB/H6o2MAAQgKCkJVVRX27t2LiYmJNQEIDg7GyZMnUVlZCX9/fxw5cgTJyckYHh7+5wBotVps2rQJs7OzmJmZgaIoUKvVWLduHQwGAxYWFsS4SqWCt7c3xsfHsWRchL3WDCdbFabmFJjMwAZHFfSLCvQGBda2dnBzcwNtW1tbw8nJCT09PWLb19cXjo6OYpP23d3dUV5ejvj4eLx+/RoODg6Ym5uTvbiefj1//lzm6nQ6JCYmoqOjA+Hh4Th69KgAMDo6Cnt7e9mT8wikyWT6CygrMoCB0ujS0hJu3LghBjw8PLB79248evQIjx8/lqwwiNzcXNRf/h6+znr4upnxmYsaQy9NeLWgwN9Tgwm9CT/2G2G9QYfEpGQJhlm2s7PDuXPnEBYWJo7b2toKGAyU+yYlJYH09vPzw65duyQRBIDrCUBfXx9u3ryJrVu3ytxbt24hNDRUGLBv3z7xLyIiAq6urnj48CH6+/thNBo/DID169fj2LFj2L9/vzgxMjKCgwcPorCwEBcvXkRTUxOmp6exZ88eeQ4L+hzlcQq+8FPDzVGNWYMZk3ozdBs1MJoUHP9Bj1GXcNRcbsTk5KQ48+zZMwngypUrePLkiTzTaWZ/586dwjImIS0tDTk5ORgcHMSDBw+EKT4+PtixY4eUSmBgIOrq6iRwagAZwPkEIyUlBffu3cOFCxekJFbSkhUZQLpv374dDQ0NQsX79+9L0Js3b0ZnZ6fQ7fbt23J/9+5dlH37DRoSHBCr08JBS5PvjtKf5vGrfRjOV9aJswya4tbS0gIXFxfJGFlGijo7OyM7OxupqalCZQLA4Chs3d3dUnYxMTHiW0ZGhgCyHIAzZ86Iv15eXuJzW1sb5ufnV9WDVUWQmTh16pTQ7/r166LId+7cEYXmoOhcvXpVvr8cG0ZJqD3it2jh52z1djMeMBZMCjI752DQReB8eYWI27Vr14SOzGpZWRkuXbr0dg3Lgwxg1ggCAeBFNg4MDMi8yMhINDY24sSJE/K8HICioiKxzfXca3FxcU0xXBUAjUaDbdu2ob29HbwnqqWlpZIdUp9lwaxRqEitEHcNUr2t8aXOBs4alZyuFk0Kfp424avuOWwJjMJ3lZXvANDV1SVZzc/PF6epAdSCuLg4eUcKM3gCQQAI2PsAYDt88eKFlNDZs2fR29srDKDtlcaabZAC0traKnVGOlJMSLv09HTJQlRUlNTlm44AxG7U4rjOBrFuWnC/IYMZab/o8dsrEyKiY1BR8YYBpCbVndQuKSkRW1RtgkDq1tbWinhRf/4uALTJtpiXlyeiefjwYRFuS+f6MwhrAsCWExISIqLC2nr69KmIVHR0NEg1lgNV2zJY/p42KhRtsYOPjRpfD8zj93kzjApkDeleU1OD5uZmAYDZJpUJgCVLLAECQY1g5skCXjzgDA0NyVbsGvX19eITR3V1tYg2W3dmZqaAxlZLFtH26dOnpXxXAuG9ByEKIp1ia7LQiO9YFgxiJUQ1KoCGGbiFeJY1FLrl/Zgg89vyYdmHQFj2t5QI51ls0ScO2uB3CqQFQL6nj3zHeaudJt8LwJoK8h/4+AmAT3+DH9nf4L9dVX8AiLu3H2a20lwAAAAASUVORK5CYII=")

def main(config):
	API_Key_Wordnik = config.get("api_key")
	WORD_OF_DAY_URI = "https://api.wordnik.com/v4/words.json/wordOfTheDay?api_key=" + API_Key_Wordnik

	word_of_day_cached = cache.get("word_of_the_day")
	if word_of_day_cached != None:
		print("pulling word from cache")
		response = json.decode(word_of_day_cached)
	else:
		print("pulling word fresh")
		response = http.get(WORD_OF_DAY_URI)
		if(response.status_code != 200):
			fail("Wordnik request failed with status %d", response.status_code)
		response = response.json()
		cache.set("word_of_the_day", json.encode(response), ttl_seconds = 43200)

	word = response["word"]
	definition = response["definitions"][0]["text"]
	part_of_speech = response["definitions"][0]["partOfSpeech"]
	if part_of_speech == "adjective":
		part_of_speech = "adj."
	if part_of_speech == "adverb":
		part_of_speech = "adv."

	definition_word_count = len(definition.split())

	#word_font = "CG-pixel-3x5-mono"
	#word_font = "tb-8"
	word_font = "5x8"

	return render.Root(
		delay = 60,
		child = render.Marquee(
			height = 32 + int((definition_word_count * 3)),
			scroll_direction = "vertical",
			offset_start = 32,
			offset_end = 33,
			child = render.Column(
				cross_align = "center",
				children = [
					# render.Image(src=WORDNIK_ICON),
					render.Padding(
						child = render.WrappedText("Word of the Day", font="Dina_r400-6", color="#afa"),
						pad = (0,0,0,4)
					),
					render.Padding(
						child = render.Column(
							children = [
								render.Text(word, color="#9cf", font = word_font),
								render.Text(part_of_speech.lower(), color = "#9c9c9c")
							]
						),
						pad = (0,0,0,5)
					),
					render.WrappedText(
						width = 64,
						linespacing = -1,
		 				content = definition,
						color="#cfcfcf"
		 			),
					render.Padding(
						render.Text(word, color="#9cf", font = word_font),
						pad = (0,3,0,0)
					),
					render.Box(
						width=64,
						height=1,
						color="#111"
					)
				]
			)
		)
	)

