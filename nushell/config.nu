use std/dirs

$env.config.shell_integration.osc9_9 = false
$env.config.shell_integration.osc133 = false

# OS-specific PATH setup
if $nu.os-info.name == "windows" {
    $env.PATH = ($env.PATH | split row ";" | append "C:/Program Files/Neovim/bin")
} else if $nu.os-info.name == "macos" {
    $env.PATH = ($env.PATH | split row ":" | prepend "/opt/homebrew/bin" | prepend "/usr/local/bin")
} else {
    # Linux - add common paths
    $env.PATH = ($env.PATH | split row ":" | prepend "/usr/local/bin")
}

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

# Load and apply the Rose Pine Moon theme
# Source from the same directory as this config file
source ($nu.default-config-dir | path join "rose-pine-moon.nu")

# Apply the color configuration
$env.config = ($env.config | upsert color_config (main))

# Rose Pine Moon LS_COLORS - matches the theme colors
$env.LS_COLORS = "di=1;38;2;62;143;176:ln=38;2;196;167;231:ex=1;38;2;156;207;216:*.zip=38;2;235;111;146:*.tar=38;2;235;111;146:*.gz=38;2;235;111;146:*.7z=38;2;235;111;146:*.rar=38;2;235;111;146:*.yml=38;2;246;193;119:*.yaml=38;2;246;193;119:*.toml=38;2;246;193;119:*.ini=38;2;246;193;119:*.conf=38;2;246;193;119:*.config=38;2;246;193;119:*.sh=38;2;156;207;216:*.bash=38;2;156;207;216:*.zsh=38;2;156;207;216:*.fish=38;2;156;207;216:*.nu=38;2;156;207;216:*.js=38;2;246;193;119:*.ts=38;2;156;207;216:*.jsx=38;2;246;193;119:*.tsx=38;2;156;207;216:*.json=38;2;246;193;119:*.md=38;2;224;222;244:*.txt=38;2;224;222;244:*.log=38;2;110;106;134:*.rs=38;2;234;154;151:*.py=38;2;246;193;119:*.rb=38;2;235;111;146:*.go=38;2;156;207;216:*.lua=38;2;196;167;231:*.vim=38;2;196;167;231:*.c=38;2;156;207;216:*.cpp=38;2;156;207;216:*.h=38;2;196;167;231:*.hpp=38;2;196;167;231:*.cs=38;2;196;167;231:*.java=38;2;234;154;151:*.class=38;2;110;106;134:fi=0;38;2;224;222;244"

# Enable ls to use colors on all platforms
$env.config = ($env.config | upsert ls {
    use_ls_colors: true
    clickable_links: true
})

# Starship prompt configuration
$env.STARSHIP_SHELL = "nu"

def create_left_prompt [] {
    starship prompt --cmd-duration $env.CMD_DURATION_MS $'--status=($env.LAST_EXIT_CODE)'
}

def create_right_prompt [] {
    # Empty right prompt or you can add time/git info here
    ""
}

$env.PROMPT_COMMAND = { || create_left_prompt }
$env.PROMPT_COMMAND_RIGHT = { || create_right_prompt }
$env.PROMPT_INDICATOR = { || " > " }
$env.PROMPT_INDICATOR_VI_INSERT = { || ": " }
$env.PROMPT_INDICATOR_VI_NORMAL = { || "> " }
$env.PROMPT_MULTILINE_INDICATOR = { || "::: " }
