class Builder
{
    public function new() { }

    public function parse(data : String)
    {
        var x = 0;
        var y = 0;

        for (i in 0...data.length)
        {
            var char = data.charAt(i);

            if (char == "?")
            {
                trace("TEST");
                continue;
            }
            if (char == '\n') 
            {
                x = 0;
                y++;

                continue;
            }

            trace('Char : ${char}/${char.charCodeAt(0)}/${"?".charCodeAt(0)} At :${x}/${y}');
            x++;
        }
    }
}