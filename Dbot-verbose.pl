use IO::Socket;

# Connect to one server of irc.quakenet.org
$s = IO::Socket::INET->new("158.38.8.251:6667");

# o("txt") writes "txt\n" to the server
sub o{ print$s "$_[0]\n" }

# Register our nickname, same as file name
o("NICK $0");
# Register username, necessary stuff :<
o("USER b * * :b");

# Never quit!
while(<$s>) {
    # Play a bit of ping-pong
    o("PONG$1") if /^PING(.*)$/;

    # Join when ping-pong has completed
    o("JOIN #$0") if /004/;

    # Parse a message our channel with message ".<cmd>"
    # so example:
    # :<user-info> PRIVMSG #<channel> :.<cmd>
    # (P.+)     Match 'PRIVMSG #<channel> :'
    # \.        Cmd prefix
    # (.*)      Cmd
    # .         Trailing \r
    if(($p,$h) = /(P.+)\.(.*)./) {
        # .hello Echo hello world! Unless an abuser appears!
        o("$p$h world!") if $h =~ "h";
        # .name Echo name of bot
        o($p.$0) if $h =~ "n";

        # .src Output whole source code
        if($h =~ "s") {
            # Open running script file handler
            open F,$0;
            # Echo contents of running script
            #         file slurping
            o($p . do{ local$/ = <F> })
        }
    }
}

