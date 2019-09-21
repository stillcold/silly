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

Handshake 0x2003 {
	.name:string 1
}

HandshakeDone 0x2004 {
	.val:string 1
}

rrpc_name 0x2005 {
	.val:integer 1
	.suffix:string 2
}

GetSearchRepoOverview 0x2006 {
	
}

ReplySearchRepoOverview 0x2007 {
	.overview:string 1
}

]]

return proto

