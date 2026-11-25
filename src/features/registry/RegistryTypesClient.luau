export type Command = {
	name: string,
	callback: CommandCallback,
}

export type CommandCallback = (CommandCallbackConfig) -> ()

export type CommandCallbackConfig = {
	name: string,
	args: { string }?,
	argsString: string?,
}

return nil
