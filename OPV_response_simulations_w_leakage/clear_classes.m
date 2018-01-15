function clear_classes()
current_breakpoints = dbstatus('-completenames');
evalin('base', 'clear classes');
% get around bug where red icons are not displayed
% by pausing for a short time
pause(0.1)
dbstop(current_breakpoints );
end
