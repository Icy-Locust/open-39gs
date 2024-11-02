ENTRY(_start)
SECTIONS {
	.text : {
		*(.text)
	}
	.data (READONLY) : {
		*(.data)
	}
	.bss : {
		*(.bss)
	}
}
