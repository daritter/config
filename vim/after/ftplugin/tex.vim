setlocal spell textwidth=80 tabstop=2 shiftwidth=2 et ai
setlocal spelllang=en | nmap <C-LeftMouse> <LeftMouse>\ls | imap <C-LeftMouse> <LeftMouse><C-O>\ls
omap lp ?^$\\|^\s*\(\\begin\\|\\end\\|\\label\\|\\sec\\|\\sub\)?1<CR>//-1<CR>.<CR>
map q gqlp
map <C-q> {gq}

set iskeyword+=:,-,_

let g:Tex_UseUtfMenus = 1
let g:Tex_ViewRule_pdf = 'evince'
let g:Tex_DefaultTargetFormat = 'pdf'
let g:Tex_SmartKeyDot = 0
let g:Tex_GotoError = 0
let g:Tex_Folding = 0

let g:Tex_Env_frame = "\\begin{frame}{<+title+>}{}\<CR><++>\<CR>\\end{frame}"
let g:Tex_Env_columns = "\\begin{columns}\<CR>\\column{<+width+>}\<CR><++>\<CR>\\end{columns}"
let g:Tex_Env_block = "\\begin{block}{<+title+>}\<CR><++>\<CR>\\end{block}"
let g:Tex_Env_exampleblock = "\\begin{exampleblock}{<+title+>}\<CR><++>\<CR>\\end{exampleblock}"
let g:Tex_Env_alertblock = "\\begin{alertblock}{<+title+>}\<CR><++>\<CR>\\end{alertblock}"
let g:Tex_FoldedSections=""
let g:Tex_FoldedEnvironments=""
let g:Tex_FoldedMisc=""
setlocal nofoldenable

function! Tex_ForwardSearchLaTeX()
python << EOF
import vim
import os
import dbus

main_file = os.path.abspath(vim.eval("Tex_GetMainFileName()"))
pdf_file = os.path.splitext(main_file)[0] + ".pdf"
tex_file = os.path.abspath(vim.current.buffer.name)
line_number =  vim.current.window.cursor[0]

try:
    bus = dbus.SessionBus()
    daemon = bus.get_object('org.gnome.evince.Daemon', '/org/gnome/evince/Daemon')
    dbus_name = daemon.FindDocument('file://' + pdf_file, True, dbus_interface = "org.gnome.evince.Daemon")
    window = bus.get_object(dbus_name, '/org/gnome/evince/Window/0')
except dbus.DBusException, e:
    print e

window.SyncView(tex_file, (line_number,1), 0, dbus_interface="org.gnome.evince.Window")
EOF
endfunction
