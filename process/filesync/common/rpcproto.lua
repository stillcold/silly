local zproto = require "zproto"

local proto = zproto:parse [[

hello 0x1001{
	.h1:integer 1
}

rrpc_sum 0x2001 {
	.val1:integer 1
	.val2:integer 2
	.suffix:string 3
}

arpc_sum 0x2002 {
	.val:integer 1
	.suffix:string 2
}

rrpc_name 0x2003 {
	.val:interger 1
	.suffix:string 2
}

arpc_name 0x2004 {
	.val:string 1
	.suffix:string 2
}


]]

return proto

