cd C:\\Users\\taylor.wisler\\Documents\\Projects

use std/dirs

$env.config.shell_integration.osc9_9 = false
$env.config.shell_integration.osc133 = false

$env.PATH = ($env.PATH | split row ";" | append "C:/Program Files/Neovim/bin")

def grep [search: string] {
	ls **/*.cs | where type == 'file' | each {
		|file|{
			file: $file.name, content: (
				open $file.name |  lines | enumerate | where item =~ $"($search)" | each {
					|match| {line_number: ($match.index + 1), content: $match.item }
				}
			)
		} 
	}
}

source "C:/Users/taylor.wisler/Documents/Projects/dotfiles/rose-pine-moon.nu"
#$env.config = ($env.config | upsert color_config (main))

$env.LS_COLORS = "di=38;2;62;143;176:ex=38;2;196;167;231:*.zip=38;2;235;111;146:*.yml=38;2;246;193;119:*.yaml=38;2;246;193;119:*.sh=38;2;158;206;106:*.js=38;2;246;193;119:*.ts=38;2;156;207;216:*.json=38;2;234;154;151:*.md=38;2;234;154;151:*.txt=38;2;224;222;244:*.log=38;2;89;84;109:fi=38;2;224;222;244"

$env.STARSHIP_SHELL = "nu"
def create_left_prompt [] {
    starship prompt --cmd-duration $env.CMD_DURATION_MS $'--status=($env.LAST_EXIT_CODE)'
}
$env.PROMPT_COMMAND = { || create_left_prompt }