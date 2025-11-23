
kernel:     file format elf32-i386


Disassembly of section .text:

80100000 <multiboot_header>:
80100000:	02 b0 ad 1b 00 00    	add    0x1bad(%eax),%dh
80100006:	00 00                	add    %al,(%eax)
80100008:	fe 4f 52             	decb   0x52(%edi)
8010000b:	e4                   	.byte 0xe4

8010000c <entry>:

# Entering xv6 on boot processor, with paging off.
.globl entry
entry:
  # Turn on page size extension for 4Mbyte pages
  movl    %cr4, %eax
8010000c:	0f 20 e0             	mov    %cr4,%eax
  orl     $(CR4_PSE), %eax
8010000f:	83 c8 10             	or     $0x10,%eax
  movl    %eax, %cr4
80100012:	0f 22 e0             	mov    %eax,%cr4
  # Set page directory
  movl    $(V2P_WO(entrypgdir)), %eax
80100015:	b8 00 a0 10 00       	mov    $0x10a000,%eax
  movl    %eax, %cr3
8010001a:	0f 22 d8             	mov    %eax,%cr3
  # Turn on paging.
  movl    %cr0, %eax
8010001d:	0f 20 c0             	mov    %cr0,%eax
  orl     $(CR0_PG|CR0_WP), %eax
80100020:	0d 00 00 01 80       	or     $0x80010000,%eax
  movl    %eax, %cr0
80100025:	0f 22 c0             	mov    %eax,%cr0

  # Set up the stack pointer.
  movl $(stack + KSTACKSIZE), %esp
80100028:	bc 60 51 11 80       	mov    $0x80115160,%esp

  # Jump to main(), and switch to executing at
  # high addresses. The indirect call is needed because
  # the assembler produces a PC-relative instruction
  # for a direct jump.
  mov $main, %eax
8010002d:	b8 b3 38 10 80       	mov    $0x801038b3,%eax
  jmp *%eax
80100032:	ff e0                	jmp    *%eax

80100034 <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
80100034:	55                   	push   %ebp
80100035:	89 e5                	mov    %esp,%ebp
80100037:	83 ec 18             	sub    $0x18,%esp
  struct buf *b;

  initlock(&bcache.lock, "bcache");
8010003a:	83 ec 08             	sub    $0x8,%esp
8010003d:	68 00 88 10 80       	push   $0x80108800
80100042:	68 c0 b5 10 80       	push   $0x8010b5c0
80100047:	e8 11 50 00 00       	call   8010505d <initlock>
8010004c:	83 c4 10             	add    $0x10,%esp

//PAGEBREAK!
  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
8010004f:	c7 05 d0 f4 10 80 c4 	movl   $0x8010f4c4,0x8010f4d0
80100056:	f4 10 80 
  bcache.head.next = &bcache.head;
80100059:	c7 05 d4 f4 10 80 c4 	movl   $0x8010f4c4,0x8010f4d4
80100060:	f4 10 80 
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
80100063:	c7 45 f4 f4 b5 10 80 	movl   $0x8010b5f4,-0xc(%ebp)
8010006a:	eb 3a                	jmp    801000a6 <binit+0x72>
    b->next = bcache.head.next;
8010006c:	8b 15 d4 f4 10 80    	mov    0x8010f4d4,%edx
80100072:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100075:	89 50 10             	mov    %edx,0x10(%eax)
    b->prev = &bcache.head;
80100078:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010007b:	c7 40 0c c4 f4 10 80 	movl   $0x8010f4c4,0xc(%eax)
    b->dev = -1;
80100082:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100085:	c7 40 04 ff ff ff ff 	movl   $0xffffffff,0x4(%eax)
    bcache.head.next->prev = b;
8010008c:	a1 d4 f4 10 80       	mov    0x8010f4d4,%eax
80100091:	8b 55 f4             	mov    -0xc(%ebp),%edx
80100094:	89 50 0c             	mov    %edx,0xc(%eax)
    bcache.head.next = b;
80100097:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010009a:	a3 d4 f4 10 80       	mov    %eax,0x8010f4d4
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
8010009f:	81 45 f4 18 02 00 00 	addl   $0x218,-0xc(%ebp)
801000a6:	b8 c4 f4 10 80       	mov    $0x8010f4c4,%eax
801000ab:	39 45 f4             	cmp    %eax,-0xc(%ebp)
801000ae:	72 bc                	jb     8010006c <binit+0x38>
  }
}
801000b0:	90                   	nop
801000b1:	90                   	nop
801000b2:	c9                   	leave
801000b3:	c3                   	ret

801000b4 <bget>:
// Look through buffer cache for block on device dev.
// If not found, allocate a buffer.
// In either case, return B_BUSY buffer.
static struct buf*
bget(uint dev, uint blockno)
{
801000b4:	55                   	push   %ebp
801000b5:	89 e5                	mov    %esp,%ebp
801000b7:	83 ec 18             	sub    $0x18,%esp
  struct buf *b;

  acquire(&bcache.lock);
801000ba:	83 ec 0c             	sub    $0xc,%esp
801000bd:	68 c0 b5 10 80       	push   $0x8010b5c0
801000c2:	e8 b8 4f 00 00       	call   8010507f <acquire>
801000c7:	83 c4 10             	add    $0x10,%esp

 loop:
  // Is the block already cached?
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
801000ca:	a1 d4 f4 10 80       	mov    0x8010f4d4,%eax
801000cf:	89 45 f4             	mov    %eax,-0xc(%ebp)
801000d2:	eb 67                	jmp    8010013b <bget+0x87>
    if(b->dev == dev && b->blockno == blockno){
801000d4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000d7:	8b 40 04             	mov    0x4(%eax),%eax
801000da:	39 45 08             	cmp    %eax,0x8(%ebp)
801000dd:	75 53                	jne    80100132 <bget+0x7e>
801000df:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000e2:	8b 40 08             	mov    0x8(%eax),%eax
801000e5:	39 45 0c             	cmp    %eax,0xc(%ebp)
801000e8:	75 48                	jne    80100132 <bget+0x7e>
      if(!(b->flags & B_BUSY)){
801000ea:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000ed:	8b 00                	mov    (%eax),%eax
801000ef:	83 e0 01             	and    $0x1,%eax
801000f2:	85 c0                	test   %eax,%eax
801000f4:	75 27                	jne    8010011d <bget+0x69>
        b->flags |= B_BUSY;
801000f6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000f9:	8b 00                	mov    (%eax),%eax
801000fb:	83 c8 01             	or     $0x1,%eax
801000fe:	89 c2                	mov    %eax,%edx
80100100:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100103:	89 10                	mov    %edx,(%eax)
        release(&bcache.lock);
80100105:	83 ec 0c             	sub    $0xc,%esp
80100108:	68 c0 b5 10 80       	push   $0x8010b5c0
8010010d:	e8 d4 4f 00 00       	call   801050e6 <release>
80100112:	83 c4 10             	add    $0x10,%esp
        return b;
80100115:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100118:	e9 98 00 00 00       	jmp    801001b5 <bget+0x101>
      }
      sleep(b, &bcache.lock);
8010011d:	83 ec 08             	sub    $0x8,%esp
80100120:	68 c0 b5 10 80       	push   $0x8010b5c0
80100125:	ff 75 f4             	push   -0xc(%ebp)
80100128:	e8 57 4c 00 00       	call   80104d84 <sleep>
8010012d:	83 c4 10             	add    $0x10,%esp
      goto loop;
80100130:	eb 98                	jmp    801000ca <bget+0x16>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
80100132:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100135:	8b 40 10             	mov    0x10(%eax),%eax
80100138:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010013b:	81 7d f4 c4 f4 10 80 	cmpl   $0x8010f4c4,-0xc(%ebp)
80100142:	75 90                	jne    801000d4 <bget+0x20>
  }

  // Not cached; recycle some non-busy and clean buffer.
  // "clean" because B_DIRTY and !B_BUSY means log.c
  // hasn't yet committed the changes to the buffer.
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
80100144:	a1 d0 f4 10 80       	mov    0x8010f4d0,%eax
80100149:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010014c:	eb 51                	jmp    8010019f <bget+0xeb>
    if((b->flags & B_BUSY) == 0 && (b->flags & B_DIRTY) == 0){
8010014e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100151:	8b 00                	mov    (%eax),%eax
80100153:	83 e0 01             	and    $0x1,%eax
80100156:	85 c0                	test   %eax,%eax
80100158:	75 3c                	jne    80100196 <bget+0xe2>
8010015a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010015d:	8b 00                	mov    (%eax),%eax
8010015f:	83 e0 04             	and    $0x4,%eax
80100162:	85 c0                	test   %eax,%eax
80100164:	75 30                	jne    80100196 <bget+0xe2>
      b->dev = dev;
80100166:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100169:	8b 55 08             	mov    0x8(%ebp),%edx
8010016c:	89 50 04             	mov    %edx,0x4(%eax)
      b->blockno = blockno;
8010016f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100172:	8b 55 0c             	mov    0xc(%ebp),%edx
80100175:	89 50 08             	mov    %edx,0x8(%eax)
      b->flags = B_BUSY;
80100178:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010017b:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
      release(&bcache.lock);
80100181:	83 ec 0c             	sub    $0xc,%esp
80100184:	68 c0 b5 10 80       	push   $0x8010b5c0
80100189:	e8 58 4f 00 00       	call   801050e6 <release>
8010018e:	83 c4 10             	add    $0x10,%esp
      return b;
80100191:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100194:	eb 1f                	jmp    801001b5 <bget+0x101>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
80100196:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100199:	8b 40 0c             	mov    0xc(%eax),%eax
8010019c:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010019f:	81 7d f4 c4 f4 10 80 	cmpl   $0x8010f4c4,-0xc(%ebp)
801001a6:	75 a6                	jne    8010014e <bget+0x9a>
    }
  }
  panic("bget: no buffers");
801001a8:	83 ec 0c             	sub    $0xc,%esp
801001ab:	68 07 88 10 80       	push   $0x80108807
801001b0:	e8 c4 03 00 00       	call   80100579 <panic>
}
801001b5:	c9                   	leave
801001b6:	c3                   	ret

801001b7 <bread>:

// Return a B_BUSY buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
801001b7:	55                   	push   %ebp
801001b8:	89 e5                	mov    %esp,%ebp
801001ba:	83 ec 18             	sub    $0x18,%esp
  struct buf *b;

  b = bget(dev, blockno);
801001bd:	83 ec 08             	sub    $0x8,%esp
801001c0:	ff 75 0c             	push   0xc(%ebp)
801001c3:	ff 75 08             	push   0x8(%ebp)
801001c6:	e8 e9 fe ff ff       	call   801000b4 <bget>
801001cb:	83 c4 10             	add    $0x10,%esp
801001ce:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(!(b->flags & B_VALID)) {
801001d1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801001d4:	8b 00                	mov    (%eax),%eax
801001d6:	83 e0 02             	and    $0x2,%eax
801001d9:	85 c0                	test   %eax,%eax
801001db:	75 0e                	jne    801001eb <bread+0x34>
    iderw(b);
801001dd:	83 ec 0c             	sub    $0xc,%esp
801001e0:	ff 75 f4             	push   -0xc(%ebp)
801001e3:	e8 37 27 00 00       	call   8010291f <iderw>
801001e8:	83 c4 10             	add    $0x10,%esp
  }
  return b;
801001eb:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801001ee:	c9                   	leave
801001ef:	c3                   	ret

801001f0 <bwrite>:

// Write b's contents to disk.  Must be B_BUSY.
void
bwrite(struct buf *b)
{
801001f0:	55                   	push   %ebp
801001f1:	89 e5                	mov    %esp,%ebp
801001f3:	83 ec 08             	sub    $0x8,%esp
  if((b->flags & B_BUSY) == 0)
801001f6:	8b 45 08             	mov    0x8(%ebp),%eax
801001f9:	8b 00                	mov    (%eax),%eax
801001fb:	83 e0 01             	and    $0x1,%eax
801001fe:	85 c0                	test   %eax,%eax
80100200:	75 0d                	jne    8010020f <bwrite+0x1f>
    panic("bwrite");
80100202:	83 ec 0c             	sub    $0xc,%esp
80100205:	68 18 88 10 80       	push   $0x80108818
8010020a:	e8 6a 03 00 00       	call   80100579 <panic>
  b->flags |= B_DIRTY;
8010020f:	8b 45 08             	mov    0x8(%ebp),%eax
80100212:	8b 00                	mov    (%eax),%eax
80100214:	83 c8 04             	or     $0x4,%eax
80100217:	89 c2                	mov    %eax,%edx
80100219:	8b 45 08             	mov    0x8(%ebp),%eax
8010021c:	89 10                	mov    %edx,(%eax)
  iderw(b);
8010021e:	83 ec 0c             	sub    $0xc,%esp
80100221:	ff 75 08             	push   0x8(%ebp)
80100224:	e8 f6 26 00 00       	call   8010291f <iderw>
80100229:	83 c4 10             	add    $0x10,%esp
}
8010022c:	90                   	nop
8010022d:	c9                   	leave
8010022e:	c3                   	ret

8010022f <brelse>:

// Release a B_BUSY buffer.
// Move to the head of the MRU list.
void
brelse(struct buf *b)
{
8010022f:	55                   	push   %ebp
80100230:	89 e5                	mov    %esp,%ebp
80100232:	83 ec 08             	sub    $0x8,%esp
  if((b->flags & B_BUSY) == 0)
80100235:	8b 45 08             	mov    0x8(%ebp),%eax
80100238:	8b 00                	mov    (%eax),%eax
8010023a:	83 e0 01             	and    $0x1,%eax
8010023d:	85 c0                	test   %eax,%eax
8010023f:	75 0d                	jne    8010024e <brelse+0x1f>
    panic("brelse");
80100241:	83 ec 0c             	sub    $0xc,%esp
80100244:	68 1f 88 10 80       	push   $0x8010881f
80100249:	e8 2b 03 00 00       	call   80100579 <panic>

  acquire(&bcache.lock);
8010024e:	83 ec 0c             	sub    $0xc,%esp
80100251:	68 c0 b5 10 80       	push   $0x8010b5c0
80100256:	e8 24 4e 00 00       	call   8010507f <acquire>
8010025b:	83 c4 10             	add    $0x10,%esp

  b->next->prev = b->prev;
8010025e:	8b 45 08             	mov    0x8(%ebp),%eax
80100261:	8b 40 10             	mov    0x10(%eax),%eax
80100264:	8b 55 08             	mov    0x8(%ebp),%edx
80100267:	8b 52 0c             	mov    0xc(%edx),%edx
8010026a:	89 50 0c             	mov    %edx,0xc(%eax)
  b->prev->next = b->next;
8010026d:	8b 45 08             	mov    0x8(%ebp),%eax
80100270:	8b 40 0c             	mov    0xc(%eax),%eax
80100273:	8b 55 08             	mov    0x8(%ebp),%edx
80100276:	8b 52 10             	mov    0x10(%edx),%edx
80100279:	89 50 10             	mov    %edx,0x10(%eax)
  b->next = bcache.head.next;
8010027c:	8b 15 d4 f4 10 80    	mov    0x8010f4d4,%edx
80100282:	8b 45 08             	mov    0x8(%ebp),%eax
80100285:	89 50 10             	mov    %edx,0x10(%eax)
  b->prev = &bcache.head;
80100288:	8b 45 08             	mov    0x8(%ebp),%eax
8010028b:	c7 40 0c c4 f4 10 80 	movl   $0x8010f4c4,0xc(%eax)
  bcache.head.next->prev = b;
80100292:	a1 d4 f4 10 80       	mov    0x8010f4d4,%eax
80100297:	8b 55 08             	mov    0x8(%ebp),%edx
8010029a:	89 50 0c             	mov    %edx,0xc(%eax)
  bcache.head.next = b;
8010029d:	8b 45 08             	mov    0x8(%ebp),%eax
801002a0:	a3 d4 f4 10 80       	mov    %eax,0x8010f4d4

  b->flags &= ~B_BUSY;
801002a5:	8b 45 08             	mov    0x8(%ebp),%eax
801002a8:	8b 00                	mov    (%eax),%eax
801002aa:	83 e0 fe             	and    $0xfffffffe,%eax
801002ad:	89 c2                	mov    %eax,%edx
801002af:	8b 45 08             	mov    0x8(%ebp),%eax
801002b2:	89 10                	mov    %edx,(%eax)
  wakeup(b);
801002b4:	83 ec 0c             	sub    $0xc,%esp
801002b7:	ff 75 08             	push   0x8(%ebp)
801002ba:	e8 b1 4b 00 00       	call   80104e70 <wakeup>
801002bf:	83 c4 10             	add    $0x10,%esp

  release(&bcache.lock);
801002c2:	83 ec 0c             	sub    $0xc,%esp
801002c5:	68 c0 b5 10 80       	push   $0x8010b5c0
801002ca:	e8 17 4e 00 00       	call   801050e6 <release>
801002cf:	83 c4 10             	add    $0x10,%esp
}
801002d2:	90                   	nop
801002d3:	c9                   	leave
801002d4:	c3                   	ret

801002d5 <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
801002d5:	55                   	push   %ebp
801002d6:	89 e5                	mov    %esp,%ebp
801002d8:	83 ec 14             	sub    $0x14,%esp
801002db:	8b 45 08             	mov    0x8(%ebp),%eax
801002de:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
801002e2:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
801002e6:	89 c2                	mov    %eax,%edx
801002e8:	ec                   	in     (%dx),%al
801002e9:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
801002ec:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
801002f0:	c9                   	leave
801002f1:	c3                   	ret

801002f2 <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
801002f2:	55                   	push   %ebp
801002f3:	89 e5                	mov    %esp,%ebp
801002f5:	83 ec 08             	sub    $0x8,%esp
801002f8:	8b 55 08             	mov    0x8(%ebp),%edx
801002fb:	8b 45 0c             	mov    0xc(%ebp),%eax
801002fe:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80100302:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80100305:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80100309:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
8010030d:	ee                   	out    %al,(%dx)
}
8010030e:	90                   	nop
8010030f:	c9                   	leave
80100310:	c3                   	ret

80100311 <cli>:
  asm volatile("movw %0, %%gs" : : "r" (v));
}

static inline void
cli(void)
{
80100311:	55                   	push   %ebp
80100312:	89 e5                	mov    %esp,%ebp
  asm volatile("cli");
80100314:	fa                   	cli
}
80100315:	90                   	nop
80100316:	5d                   	pop    %ebp
80100317:	c3                   	ret

80100318 <printint>:
  int locking;
} cons;

static void
printint(int xx, int base, int sign)
{
80100318:	55                   	push   %ebp
80100319:	89 e5                	mov    %esp,%ebp
8010031b:	83 ec 28             	sub    $0x28,%esp
  static char digits[] = "0123456789abcdef";
  char buf[16];
  int i;
  uint x;

  if(sign && (sign = xx < 0))
8010031e:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80100322:	74 1c                	je     80100340 <printint+0x28>
80100324:	8b 45 08             	mov    0x8(%ebp),%eax
80100327:	c1 e8 1f             	shr    $0x1f,%eax
8010032a:	0f b6 c0             	movzbl %al,%eax
8010032d:	89 45 10             	mov    %eax,0x10(%ebp)
80100330:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80100334:	74 0a                	je     80100340 <printint+0x28>
    x = -xx;
80100336:	8b 45 08             	mov    0x8(%ebp),%eax
80100339:	f7 d8                	neg    %eax
8010033b:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010033e:	eb 06                	jmp    80100346 <printint+0x2e>
  else
    x = xx;
80100340:	8b 45 08             	mov    0x8(%ebp),%eax
80100343:	89 45 f0             	mov    %eax,-0x10(%ebp)

  i = 0;
80100346:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
8010034d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80100350:	8b 45 f0             	mov    -0x10(%ebp),%eax
80100353:	ba 00 00 00 00       	mov    $0x0,%edx
80100358:	f7 f1                	div    %ecx
8010035a:	89 d1                	mov    %edx,%ecx
8010035c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010035f:	8d 50 01             	lea    0x1(%eax),%edx
80100362:	89 55 f4             	mov    %edx,-0xc(%ebp)
80100365:	0f b6 91 04 90 10 80 	movzbl -0x7fef6ffc(%ecx),%edx
8010036c:	88 54 05 e0          	mov    %dl,-0x20(%ebp,%eax,1)
  }while((x /= base) != 0);
80100370:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80100373:	8b 45 f0             	mov    -0x10(%ebp),%eax
80100376:	ba 00 00 00 00       	mov    $0x0,%edx
8010037b:	f7 f1                	div    %ecx
8010037d:	89 45 f0             	mov    %eax,-0x10(%ebp)
80100380:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80100384:	75 c7                	jne    8010034d <printint+0x35>

  if(sign)
80100386:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
8010038a:	74 2a                	je     801003b6 <printint+0x9e>
    buf[i++] = '-';
8010038c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010038f:	8d 50 01             	lea    0x1(%eax),%edx
80100392:	89 55 f4             	mov    %edx,-0xc(%ebp)
80100395:	c6 44 05 e0 2d       	movb   $0x2d,-0x20(%ebp,%eax,1)

  while(--i >= 0)
8010039a:	eb 1a                	jmp    801003b6 <printint+0x9e>
    consputc(buf[i]);
8010039c:	8d 55 e0             	lea    -0x20(%ebp),%edx
8010039f:	8b 45 f4             	mov    -0xc(%ebp),%eax
801003a2:	01 d0                	add    %edx,%eax
801003a4:	0f b6 00             	movzbl (%eax),%eax
801003a7:	0f be c0             	movsbl %al,%eax
801003aa:	83 ec 0c             	sub    $0xc,%esp
801003ad:	50                   	push   %eax
801003ae:	e8 fb 03 00 00       	call   801007ae <consputc>
801003b3:	83 c4 10             	add    $0x10,%esp
  while(--i >= 0)
801003b6:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
801003ba:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801003be:	79 dc                	jns    8010039c <printint+0x84>
}
801003c0:	90                   	nop
801003c1:	90                   	nop
801003c2:	c9                   	leave
801003c3:	c3                   	ret

801003c4 <cprintf>:
//PAGEBREAK: 50

// Print to the console. only understands %d, %x, %p, %s.
void
cprintf(char *fmt, ...)
{
801003c4:	55                   	push   %ebp
801003c5:	89 e5                	mov    %esp,%ebp
801003c7:	83 ec 28             	sub    $0x28,%esp
  int i, c, locking;
  uint *argp;
  char *s;

  locking = cons.locking;
801003ca:	a1 b4 f7 10 80       	mov    0x8010f7b4,%eax
801003cf:	89 45 e8             	mov    %eax,-0x18(%ebp)
  if(locking)
801003d2:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
801003d6:	74 10                	je     801003e8 <cprintf+0x24>
    acquire(&cons.lock);
801003d8:	83 ec 0c             	sub    $0xc,%esp
801003db:	68 80 f7 10 80       	push   $0x8010f780
801003e0:	e8 9a 4c 00 00       	call   8010507f <acquire>
801003e5:	83 c4 10             	add    $0x10,%esp

  if (fmt == 0)
801003e8:	8b 45 08             	mov    0x8(%ebp),%eax
801003eb:	85 c0                	test   %eax,%eax
801003ed:	75 0d                	jne    801003fc <cprintf+0x38>
    panic("null fmt");
801003ef:	83 ec 0c             	sub    $0xc,%esp
801003f2:	68 26 88 10 80       	push   $0x80108826
801003f7:	e8 7d 01 00 00       	call   80100579 <panic>

  argp = (uint*)(void*)(&fmt + 1);
801003fc:	8d 45 0c             	lea    0xc(%ebp),%eax
801003ff:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
80100402:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80100409:	e9 2f 01 00 00       	jmp    8010053d <cprintf+0x179>
    if(c != '%'){
8010040e:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
80100412:	74 13                	je     80100427 <cprintf+0x63>
      consputc(c);
80100414:	83 ec 0c             	sub    $0xc,%esp
80100417:	ff 75 e4             	push   -0x1c(%ebp)
8010041a:	e8 8f 03 00 00       	call   801007ae <consputc>
8010041f:	83 c4 10             	add    $0x10,%esp
      continue;
80100422:	e9 12 01 00 00       	jmp    80100539 <cprintf+0x175>
    }
    c = fmt[++i] & 0xff;
80100427:	8b 55 08             	mov    0x8(%ebp),%edx
8010042a:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010042e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100431:	01 d0                	add    %edx,%eax
80100433:	0f b6 00             	movzbl (%eax),%eax
80100436:	0f be c0             	movsbl %al,%eax
80100439:	25 ff 00 00 00       	and    $0xff,%eax
8010043e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(c == 0)
80100441:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
80100445:	0f 84 14 01 00 00    	je     8010055f <cprintf+0x19b>
      break;
    switch(c){
8010044b:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
8010044f:	74 5e                	je     801004af <cprintf+0xeb>
80100451:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
80100455:	0f 8f c2 00 00 00    	jg     8010051d <cprintf+0x159>
8010045b:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
8010045f:	74 6b                	je     801004cc <cprintf+0x108>
80100461:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
80100465:	0f 8f b2 00 00 00    	jg     8010051d <cprintf+0x159>
8010046b:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
8010046f:	74 3e                	je     801004af <cprintf+0xeb>
80100471:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
80100475:	0f 8f a2 00 00 00    	jg     8010051d <cprintf+0x159>
8010047b:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
8010047f:	0f 84 89 00 00 00    	je     8010050e <cprintf+0x14a>
80100485:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
80100489:	0f 85 8e 00 00 00    	jne    8010051d <cprintf+0x159>
    case 'd':
      printint(*argp++, 10, 1);
8010048f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80100492:	8d 50 04             	lea    0x4(%eax),%edx
80100495:	89 55 f0             	mov    %edx,-0x10(%ebp)
80100498:	8b 00                	mov    (%eax),%eax
8010049a:	83 ec 04             	sub    $0x4,%esp
8010049d:	6a 01                	push   $0x1
8010049f:	6a 0a                	push   $0xa
801004a1:	50                   	push   %eax
801004a2:	e8 71 fe ff ff       	call   80100318 <printint>
801004a7:	83 c4 10             	add    $0x10,%esp
      break;
801004aa:	e9 8a 00 00 00       	jmp    80100539 <cprintf+0x175>
    case 'x':
    case 'p':
      printint(*argp++, 16, 0);
801004af:	8b 45 f0             	mov    -0x10(%ebp),%eax
801004b2:	8d 50 04             	lea    0x4(%eax),%edx
801004b5:	89 55 f0             	mov    %edx,-0x10(%ebp)
801004b8:	8b 00                	mov    (%eax),%eax
801004ba:	83 ec 04             	sub    $0x4,%esp
801004bd:	6a 00                	push   $0x0
801004bf:	6a 10                	push   $0x10
801004c1:	50                   	push   %eax
801004c2:	e8 51 fe ff ff       	call   80100318 <printint>
801004c7:	83 c4 10             	add    $0x10,%esp
      break;
801004ca:	eb 6d                	jmp    80100539 <cprintf+0x175>
    case 's':
      if((s = (char*)*argp++) == 0)
801004cc:	8b 45 f0             	mov    -0x10(%ebp),%eax
801004cf:	8d 50 04             	lea    0x4(%eax),%edx
801004d2:	89 55 f0             	mov    %edx,-0x10(%ebp)
801004d5:	8b 00                	mov    (%eax),%eax
801004d7:	89 45 ec             	mov    %eax,-0x14(%ebp)
801004da:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
801004de:	75 22                	jne    80100502 <cprintf+0x13e>
        s = "(null)";
801004e0:	c7 45 ec 2f 88 10 80 	movl   $0x8010882f,-0x14(%ebp)
      for(; *s; s++)
801004e7:	eb 19                	jmp    80100502 <cprintf+0x13e>
        consputc(*s);
801004e9:	8b 45 ec             	mov    -0x14(%ebp),%eax
801004ec:	0f b6 00             	movzbl (%eax),%eax
801004ef:	0f be c0             	movsbl %al,%eax
801004f2:	83 ec 0c             	sub    $0xc,%esp
801004f5:	50                   	push   %eax
801004f6:	e8 b3 02 00 00       	call   801007ae <consputc>
801004fb:	83 c4 10             	add    $0x10,%esp
      for(; *s; s++)
801004fe:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
80100502:	8b 45 ec             	mov    -0x14(%ebp),%eax
80100505:	0f b6 00             	movzbl (%eax),%eax
80100508:	84 c0                	test   %al,%al
8010050a:	75 dd                	jne    801004e9 <cprintf+0x125>
      break;
8010050c:	eb 2b                	jmp    80100539 <cprintf+0x175>
    case '%':
      consputc('%');
8010050e:	83 ec 0c             	sub    $0xc,%esp
80100511:	6a 25                	push   $0x25
80100513:	e8 96 02 00 00       	call   801007ae <consputc>
80100518:	83 c4 10             	add    $0x10,%esp
      break;
8010051b:	eb 1c                	jmp    80100539 <cprintf+0x175>
    default:
      // Print unknown % sequence to draw attention.
      consputc('%');
8010051d:	83 ec 0c             	sub    $0xc,%esp
80100520:	6a 25                	push   $0x25
80100522:	e8 87 02 00 00       	call   801007ae <consputc>
80100527:	83 c4 10             	add    $0x10,%esp
      consputc(c);
8010052a:	83 ec 0c             	sub    $0xc,%esp
8010052d:	ff 75 e4             	push   -0x1c(%ebp)
80100530:	e8 79 02 00 00       	call   801007ae <consputc>
80100535:	83 c4 10             	add    $0x10,%esp
      break;
80100538:	90                   	nop
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
80100539:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010053d:	8b 55 08             	mov    0x8(%ebp),%edx
80100540:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100543:	01 d0                	add    %edx,%eax
80100545:	0f b6 00             	movzbl (%eax),%eax
80100548:	0f be c0             	movsbl %al,%eax
8010054b:	25 ff 00 00 00       	and    $0xff,%eax
80100550:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80100553:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
80100557:	0f 85 b1 fe ff ff    	jne    8010040e <cprintf+0x4a>
8010055d:	eb 01                	jmp    80100560 <cprintf+0x19c>
      break;
8010055f:	90                   	nop
    }
  }

  if(locking)
80100560:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
80100564:	74 10                	je     80100576 <cprintf+0x1b2>
    release(&cons.lock);
80100566:	83 ec 0c             	sub    $0xc,%esp
80100569:	68 80 f7 10 80       	push   $0x8010f780
8010056e:	e8 73 4b 00 00       	call   801050e6 <release>
80100573:	83 c4 10             	add    $0x10,%esp
}
80100576:	90                   	nop
80100577:	c9                   	leave
80100578:	c3                   	ret

80100579 <panic>:

void
panic(char *s)
{
80100579:	55                   	push   %ebp
8010057a:	89 e5                	mov    %esp,%ebp
8010057c:	83 ec 38             	sub    $0x38,%esp
  int i;
  uint pcs[10];
  
  cli();
8010057f:	e8 8d fd ff ff       	call   80100311 <cli>
  cons.locking = 0;
80100584:	c7 05 b4 f7 10 80 00 	movl   $0x0,0x8010f7b4
8010058b:	00 00 00 
  cprintf("cpu%d: panic: ", cpu->id);
8010058e:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80100594:	0f b6 00             	movzbl (%eax),%eax
80100597:	0f b6 c0             	movzbl %al,%eax
8010059a:	83 ec 08             	sub    $0x8,%esp
8010059d:	50                   	push   %eax
8010059e:	68 36 88 10 80       	push   $0x80108836
801005a3:	e8 1c fe ff ff       	call   801003c4 <cprintf>
801005a8:	83 c4 10             	add    $0x10,%esp
  cprintf(s);
801005ab:	8b 45 08             	mov    0x8(%ebp),%eax
801005ae:	83 ec 0c             	sub    $0xc,%esp
801005b1:	50                   	push   %eax
801005b2:	e8 0d fe ff ff       	call   801003c4 <cprintf>
801005b7:	83 c4 10             	add    $0x10,%esp
  cprintf("\n");
801005ba:	83 ec 0c             	sub    $0xc,%esp
801005bd:	68 45 88 10 80       	push   $0x80108845
801005c2:	e8 fd fd ff ff       	call   801003c4 <cprintf>
801005c7:	83 c4 10             	add    $0x10,%esp
  getcallerpcs(&s, pcs);
801005ca:	83 ec 08             	sub    $0x8,%esp
801005cd:	8d 45 cc             	lea    -0x34(%ebp),%eax
801005d0:	50                   	push   %eax
801005d1:	8d 45 08             	lea    0x8(%ebp),%eax
801005d4:	50                   	push   %eax
801005d5:	e8 5e 4b 00 00       	call   80105138 <getcallerpcs>
801005da:	83 c4 10             	add    $0x10,%esp
  for(i=0; i<10; i++)
801005dd:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801005e4:	eb 1c                	jmp    80100602 <panic+0x89>
    cprintf(" %p", pcs[i]);
801005e6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801005e9:	8b 44 85 cc          	mov    -0x34(%ebp,%eax,4),%eax
801005ed:	83 ec 08             	sub    $0x8,%esp
801005f0:	50                   	push   %eax
801005f1:	68 47 88 10 80       	push   $0x80108847
801005f6:	e8 c9 fd ff ff       	call   801003c4 <cprintf>
801005fb:	83 c4 10             	add    $0x10,%esp
  for(i=0; i<10; i++)
801005fe:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80100602:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
80100606:	7e de                	jle    801005e6 <panic+0x6d>
  panicked = 1; // freeze other CPU
80100608:	c7 05 6c f7 10 80 01 	movl   $0x1,0x8010f76c
8010060f:	00 00 00 
  for(;;)
80100612:	90                   	nop
80100613:	eb fd                	jmp    80100612 <panic+0x99>

80100615 <cgaputc>:
#define CRTPORT 0x3d4
static ushort *crt = (ushort*)P2V(0xb8000);  // CGA memory

static void
cgaputc(int c)
{
80100615:	55                   	push   %ebp
80100616:	89 e5                	mov    %esp,%ebp
80100618:	53                   	push   %ebx
80100619:	83 ec 14             	sub    $0x14,%esp
  int pos;
  
  // Cursor position: col + 80*row.
  outb(CRTPORT, 14);
8010061c:	6a 0e                	push   $0xe
8010061e:	68 d4 03 00 00       	push   $0x3d4
80100623:	e8 ca fc ff ff       	call   801002f2 <outb>
80100628:	83 c4 08             	add    $0x8,%esp
  pos = inb(CRTPORT+1) << 8;
8010062b:	68 d5 03 00 00       	push   $0x3d5
80100630:	e8 a0 fc ff ff       	call   801002d5 <inb>
80100635:	83 c4 04             	add    $0x4,%esp
80100638:	0f b6 c0             	movzbl %al,%eax
8010063b:	c1 e0 08             	shl    $0x8,%eax
8010063e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  outb(CRTPORT, 15);
80100641:	6a 0f                	push   $0xf
80100643:	68 d4 03 00 00       	push   $0x3d4
80100648:	e8 a5 fc ff ff       	call   801002f2 <outb>
8010064d:	83 c4 08             	add    $0x8,%esp
  pos |= inb(CRTPORT+1);
80100650:	68 d5 03 00 00       	push   $0x3d5
80100655:	e8 7b fc ff ff       	call   801002d5 <inb>
8010065a:	83 c4 04             	add    $0x4,%esp
8010065d:	0f b6 c0             	movzbl %al,%eax
80100660:	09 45 f4             	or     %eax,-0xc(%ebp)

  if(c == '\n')
80100663:	83 7d 08 0a          	cmpl   $0xa,0x8(%ebp)
80100667:	75 30                	jne    80100699 <cgaputc+0x84>
    pos += 80 - pos%80;
80100669:	8b 4d f4             	mov    -0xc(%ebp),%ecx
8010066c:	ba 67 66 66 66       	mov    $0x66666667,%edx
80100671:	89 c8                	mov    %ecx,%eax
80100673:	f7 ea                	imul   %edx
80100675:	c1 fa 05             	sar    $0x5,%edx
80100678:	89 c8                	mov    %ecx,%eax
8010067a:	c1 f8 1f             	sar    $0x1f,%eax
8010067d:	29 c2                	sub    %eax,%edx
8010067f:	89 d0                	mov    %edx,%eax
80100681:	c1 e0 02             	shl    $0x2,%eax
80100684:	01 d0                	add    %edx,%eax
80100686:	c1 e0 04             	shl    $0x4,%eax
80100689:	29 c1                	sub    %eax,%ecx
8010068b:	89 ca                	mov    %ecx,%edx
8010068d:	b8 50 00 00 00       	mov    $0x50,%eax
80100692:	29 d0                	sub    %edx,%eax
80100694:	01 45 f4             	add    %eax,-0xc(%ebp)
80100697:	eb 38                	jmp    801006d1 <cgaputc+0xbc>
  else if(c == BACKSPACE){
80100699:	81 7d 08 00 01 00 00 	cmpl   $0x100,0x8(%ebp)
801006a0:	75 0c                	jne    801006ae <cgaputc+0x99>
    if(pos > 0) --pos;
801006a2:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801006a6:	7e 29                	jle    801006d1 <cgaputc+0xbc>
801006a8:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
801006ac:	eb 23                	jmp    801006d1 <cgaputc+0xbc>
  } else
    crt[pos++] = (c&0xff) | 0x0700;  // black on white
801006ae:	8b 45 08             	mov    0x8(%ebp),%eax
801006b1:	0f b6 c0             	movzbl %al,%eax
801006b4:	80 cc 07             	or     $0x7,%ah
801006b7:	89 c3                	mov    %eax,%ebx
801006b9:	8b 0d 00 90 10 80    	mov    0x80109000,%ecx
801006bf:	8b 45 f4             	mov    -0xc(%ebp),%eax
801006c2:	8d 50 01             	lea    0x1(%eax),%edx
801006c5:	89 55 f4             	mov    %edx,-0xc(%ebp)
801006c8:	01 c0                	add    %eax,%eax
801006ca:	01 c8                	add    %ecx,%eax
801006cc:	89 da                	mov    %ebx,%edx
801006ce:	66 89 10             	mov    %dx,(%eax)

  if(pos < 0 || pos > 25*80)
801006d1:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801006d5:	78 09                	js     801006e0 <cgaputc+0xcb>
801006d7:	81 7d f4 d0 07 00 00 	cmpl   $0x7d0,-0xc(%ebp)
801006de:	7e 0d                	jle    801006ed <cgaputc+0xd8>
    panic("pos under/overflow");
801006e0:	83 ec 0c             	sub    $0xc,%esp
801006e3:	68 4b 88 10 80       	push   $0x8010884b
801006e8:	e8 8c fe ff ff       	call   80100579 <panic>
  
  if((pos/80) >= 24){  // Scroll up.
801006ed:	81 7d f4 7f 07 00 00 	cmpl   $0x77f,-0xc(%ebp)
801006f4:	7e 4c                	jle    80100742 <cgaputc+0x12d>
    memmove(crt, crt+80, sizeof(crt[0])*23*80);
801006f6:	a1 00 90 10 80       	mov    0x80109000,%eax
801006fb:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
80100701:	a1 00 90 10 80       	mov    0x80109000,%eax
80100706:	83 ec 04             	sub    $0x4,%esp
80100709:	68 60 0e 00 00       	push   $0xe60
8010070e:	52                   	push   %edx
8010070f:	50                   	push   %eax
80100710:	e8 8d 4c 00 00       	call   801053a2 <memmove>
80100715:	83 c4 10             	add    $0x10,%esp
    pos -= 80;
80100718:	83 6d f4 50          	subl   $0x50,-0xc(%ebp)
    memset(crt+pos, 0, sizeof(crt[0])*(24*80 - pos));
8010071c:	b8 80 07 00 00       	mov    $0x780,%eax
80100721:	2b 45 f4             	sub    -0xc(%ebp),%eax
80100724:	8d 14 00             	lea    (%eax,%eax,1),%edx
80100727:	a1 00 90 10 80       	mov    0x80109000,%eax
8010072c:	8b 4d f4             	mov    -0xc(%ebp),%ecx
8010072f:	01 c9                	add    %ecx,%ecx
80100731:	01 c8                	add    %ecx,%eax
80100733:	83 ec 04             	sub    $0x4,%esp
80100736:	52                   	push   %edx
80100737:	6a 00                	push   $0x0
80100739:	50                   	push   %eax
8010073a:	e8 a4 4b 00 00       	call   801052e3 <memset>
8010073f:	83 c4 10             	add    $0x10,%esp
  }
  
  outb(CRTPORT, 14);
80100742:	83 ec 08             	sub    $0x8,%esp
80100745:	6a 0e                	push   $0xe
80100747:	68 d4 03 00 00       	push   $0x3d4
8010074c:	e8 a1 fb ff ff       	call   801002f2 <outb>
80100751:	83 c4 10             	add    $0x10,%esp
  outb(CRTPORT+1, pos>>8);
80100754:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100757:	c1 f8 08             	sar    $0x8,%eax
8010075a:	0f b6 c0             	movzbl %al,%eax
8010075d:	83 ec 08             	sub    $0x8,%esp
80100760:	50                   	push   %eax
80100761:	68 d5 03 00 00       	push   $0x3d5
80100766:	e8 87 fb ff ff       	call   801002f2 <outb>
8010076b:	83 c4 10             	add    $0x10,%esp
  outb(CRTPORT, 15);
8010076e:	83 ec 08             	sub    $0x8,%esp
80100771:	6a 0f                	push   $0xf
80100773:	68 d4 03 00 00       	push   $0x3d4
80100778:	e8 75 fb ff ff       	call   801002f2 <outb>
8010077d:	83 c4 10             	add    $0x10,%esp
  outb(CRTPORT+1, pos);
80100780:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100783:	0f b6 c0             	movzbl %al,%eax
80100786:	83 ec 08             	sub    $0x8,%esp
80100789:	50                   	push   %eax
8010078a:	68 d5 03 00 00       	push   $0x3d5
8010078f:	e8 5e fb ff ff       	call   801002f2 <outb>
80100794:	83 c4 10             	add    $0x10,%esp
  crt[pos] = ' ' | 0x0700;
80100797:	a1 00 90 10 80       	mov    0x80109000,%eax
8010079c:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010079f:	01 d2                	add    %edx,%edx
801007a1:	01 d0                	add    %edx,%eax
801007a3:	66 c7 00 20 07       	movw   $0x720,(%eax)
}
801007a8:	90                   	nop
801007a9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801007ac:	c9                   	leave
801007ad:	c3                   	ret

801007ae <consputc>:

void
consputc(int c)
{
801007ae:	55                   	push   %ebp
801007af:	89 e5                	mov    %esp,%ebp
801007b1:	83 ec 08             	sub    $0x8,%esp
  if(panicked){
801007b4:	a1 6c f7 10 80       	mov    0x8010f76c,%eax
801007b9:	85 c0                	test   %eax,%eax
801007bb:	74 08                	je     801007c5 <consputc+0x17>
    cli();
801007bd:	e8 4f fb ff ff       	call   80100311 <cli>
    for(;;)
801007c2:	90                   	nop
801007c3:	eb fd                	jmp    801007c2 <consputc+0x14>
      ;
  }

  if(c == BACKSPACE){
801007c5:	81 7d 08 00 01 00 00 	cmpl   $0x100,0x8(%ebp)
801007cc:	75 29                	jne    801007f7 <consputc+0x49>
    uartputc('\b'); uartputc(' '); uartputc('\b');
801007ce:	83 ec 0c             	sub    $0xc,%esp
801007d1:	6a 08                	push   $0x8
801007d3:	e8 b3 66 00 00       	call   80106e8b <uartputc>
801007d8:	83 c4 10             	add    $0x10,%esp
801007db:	83 ec 0c             	sub    $0xc,%esp
801007de:	6a 20                	push   $0x20
801007e0:	e8 a6 66 00 00       	call   80106e8b <uartputc>
801007e5:	83 c4 10             	add    $0x10,%esp
801007e8:	83 ec 0c             	sub    $0xc,%esp
801007eb:	6a 08                	push   $0x8
801007ed:	e8 99 66 00 00       	call   80106e8b <uartputc>
801007f2:	83 c4 10             	add    $0x10,%esp
801007f5:	eb 0e                	jmp    80100805 <consputc+0x57>
  } else
    uartputc(c);
801007f7:	83 ec 0c             	sub    $0xc,%esp
801007fa:	ff 75 08             	push   0x8(%ebp)
801007fd:	e8 89 66 00 00       	call   80106e8b <uartputc>
80100802:	83 c4 10             	add    $0x10,%esp
  cgaputc(c);
80100805:	83 ec 0c             	sub    $0xc,%esp
80100808:	ff 75 08             	push   0x8(%ebp)
8010080b:	e8 05 fe ff ff       	call   80100615 <cgaputc>
80100810:	83 c4 10             	add    $0x10,%esp
}
80100813:	90                   	nop
80100814:	c9                   	leave
80100815:	c3                   	ret

80100816 <consoleintr>:

#define C(x)  ((x)-'@')  // Control-x

void
consoleintr(int (*getc)(void))
{
80100816:	55                   	push   %ebp
80100817:	89 e5                	mov    %esp,%ebp
80100819:	83 ec 18             	sub    $0x18,%esp
  int c, doprocdump = 0;
8010081c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

  acquire(&cons.lock);
80100823:	83 ec 0c             	sub    $0xc,%esp
80100826:	68 80 f7 10 80       	push   $0x8010f780
8010082b:	e8 4f 48 00 00       	call   8010507f <acquire>
80100830:	83 c4 10             	add    $0x10,%esp
  while((c = getc()) >= 0){
80100833:	e9 58 01 00 00       	jmp    80100990 <consoleintr+0x17a>
    switch(c){
80100838:	83 7d f0 7f          	cmpl   $0x7f,-0x10(%ebp)
8010083c:	0f 84 81 00 00 00    	je     801008c3 <consoleintr+0xad>
80100842:	83 7d f0 7f          	cmpl   $0x7f,-0x10(%ebp)
80100846:	0f 8f ac 00 00 00    	jg     801008f8 <consoleintr+0xe2>
8010084c:	83 7d f0 15          	cmpl   $0x15,-0x10(%ebp)
80100850:	74 43                	je     80100895 <consoleintr+0x7f>
80100852:	83 7d f0 15          	cmpl   $0x15,-0x10(%ebp)
80100856:	0f 8f 9c 00 00 00    	jg     801008f8 <consoleintr+0xe2>
8010085c:	83 7d f0 08          	cmpl   $0x8,-0x10(%ebp)
80100860:	74 61                	je     801008c3 <consoleintr+0xad>
80100862:	83 7d f0 10          	cmpl   $0x10,-0x10(%ebp)
80100866:	0f 85 8c 00 00 00    	jne    801008f8 <consoleintr+0xe2>
    case C('P'):  // Process listing.
      doprocdump = 1;   // procdump() locks cons.lock indirectly; invoke later
8010086c:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
      break;
80100873:	e9 18 01 00 00       	jmp    80100990 <consoleintr+0x17a>
    case C('U'):  // Kill line.
      while(input.e != input.w &&
            input.buf[(input.e-1) % INPUT_BUF] != '\n'){
        input.e--;
80100878:	a1 68 f7 10 80       	mov    0x8010f768,%eax
8010087d:	83 e8 01             	sub    $0x1,%eax
80100880:	a3 68 f7 10 80       	mov    %eax,0x8010f768
        consputc(BACKSPACE);
80100885:	83 ec 0c             	sub    $0xc,%esp
80100888:	68 00 01 00 00       	push   $0x100
8010088d:	e8 1c ff ff ff       	call   801007ae <consputc>
80100892:	83 c4 10             	add    $0x10,%esp
      while(input.e != input.w &&
80100895:	8b 15 68 f7 10 80    	mov    0x8010f768,%edx
8010089b:	a1 64 f7 10 80       	mov    0x8010f764,%eax
801008a0:	39 c2                	cmp    %eax,%edx
801008a2:	0f 84 e1 00 00 00    	je     80100989 <consoleintr+0x173>
            input.buf[(input.e-1) % INPUT_BUF] != '\n'){
801008a8:	a1 68 f7 10 80       	mov    0x8010f768,%eax
801008ad:	83 e8 01             	sub    $0x1,%eax
801008b0:	83 e0 7f             	and    $0x7f,%eax
801008b3:	0f b6 80 e0 f6 10 80 	movzbl -0x7fef0920(%eax),%eax
      while(input.e != input.w &&
801008ba:	3c 0a                	cmp    $0xa,%al
801008bc:	75 ba                	jne    80100878 <consoleintr+0x62>
      }
      break;
801008be:	e9 c6 00 00 00       	jmp    80100989 <consoleintr+0x173>
    case C('H'): case '\x7f':  // Backspace
      if(input.e != input.w){
801008c3:	8b 15 68 f7 10 80    	mov    0x8010f768,%edx
801008c9:	a1 64 f7 10 80       	mov    0x8010f764,%eax
801008ce:	39 c2                	cmp    %eax,%edx
801008d0:	0f 84 b6 00 00 00    	je     8010098c <consoleintr+0x176>
        input.e--;
801008d6:	a1 68 f7 10 80       	mov    0x8010f768,%eax
801008db:	83 e8 01             	sub    $0x1,%eax
801008de:	a3 68 f7 10 80       	mov    %eax,0x8010f768
        consputc(BACKSPACE);
801008e3:	83 ec 0c             	sub    $0xc,%esp
801008e6:	68 00 01 00 00       	push   $0x100
801008eb:	e8 be fe ff ff       	call   801007ae <consputc>
801008f0:	83 c4 10             	add    $0x10,%esp
      }
      break;
801008f3:	e9 94 00 00 00       	jmp    8010098c <consoleintr+0x176>
    default:
      if(c != 0 && input.e-input.r < INPUT_BUF){
801008f8:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801008fc:	0f 84 8d 00 00 00    	je     8010098f <consoleintr+0x179>
80100902:	8b 15 68 f7 10 80    	mov    0x8010f768,%edx
80100908:	a1 60 f7 10 80       	mov    0x8010f760,%eax
8010090d:	29 c2                	sub    %eax,%edx
8010090f:	83 fa 7f             	cmp    $0x7f,%edx
80100912:	77 7b                	ja     8010098f <consoleintr+0x179>
        c = (c == '\r') ? '\n' : c;
80100914:	83 7d f0 0d          	cmpl   $0xd,-0x10(%ebp)
80100918:	74 05                	je     8010091f <consoleintr+0x109>
8010091a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010091d:	eb 05                	jmp    80100924 <consoleintr+0x10e>
8010091f:	b8 0a 00 00 00       	mov    $0xa,%eax
80100924:	89 45 f0             	mov    %eax,-0x10(%ebp)
        input.buf[input.e++ % INPUT_BUF] = c;
80100927:	a1 68 f7 10 80       	mov    0x8010f768,%eax
8010092c:	8d 50 01             	lea    0x1(%eax),%edx
8010092f:	89 15 68 f7 10 80    	mov    %edx,0x8010f768
80100935:	83 e0 7f             	and    $0x7f,%eax
80100938:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010093b:	88 90 e0 f6 10 80    	mov    %dl,-0x7fef0920(%eax)
        consputc(c);
80100941:	83 ec 0c             	sub    $0xc,%esp
80100944:	ff 75 f0             	push   -0x10(%ebp)
80100947:	e8 62 fe ff ff       	call   801007ae <consputc>
8010094c:	83 c4 10             	add    $0x10,%esp
        if(c == '\n' || c == C('D') || input.e == input.r+INPUT_BUF){
8010094f:	83 7d f0 0a          	cmpl   $0xa,-0x10(%ebp)
80100953:	74 18                	je     8010096d <consoleintr+0x157>
80100955:	83 7d f0 04          	cmpl   $0x4,-0x10(%ebp)
80100959:	74 12                	je     8010096d <consoleintr+0x157>
8010095b:	8b 15 68 f7 10 80    	mov    0x8010f768,%edx
80100961:	a1 60 f7 10 80       	mov    0x8010f760,%eax
80100966:	83 e8 80             	sub    $0xffffff80,%eax
80100969:	39 c2                	cmp    %eax,%edx
8010096b:	75 22                	jne    8010098f <consoleintr+0x179>
          input.w = input.e;
8010096d:	a1 68 f7 10 80       	mov    0x8010f768,%eax
80100972:	a3 64 f7 10 80       	mov    %eax,0x8010f764
          wakeup(&input.r);
80100977:	83 ec 0c             	sub    $0xc,%esp
8010097a:	68 60 f7 10 80       	push   $0x8010f760
8010097f:	e8 ec 44 00 00       	call   80104e70 <wakeup>
80100984:	83 c4 10             	add    $0x10,%esp
        }
      }
      break;
80100987:	eb 06                	jmp    8010098f <consoleintr+0x179>
      break;
80100989:	90                   	nop
8010098a:	eb 04                	jmp    80100990 <consoleintr+0x17a>
      break;
8010098c:	90                   	nop
8010098d:	eb 01                	jmp    80100990 <consoleintr+0x17a>
      break;
8010098f:	90                   	nop
  while((c = getc()) >= 0){
80100990:	8b 45 08             	mov    0x8(%ebp),%eax
80100993:	ff d0                	call   *%eax
80100995:	89 45 f0             	mov    %eax,-0x10(%ebp)
80100998:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010099c:	0f 89 96 fe ff ff    	jns    80100838 <consoleintr+0x22>
    }
  }
  release(&cons.lock);
801009a2:	83 ec 0c             	sub    $0xc,%esp
801009a5:	68 80 f7 10 80       	push   $0x8010f780
801009aa:	e8 37 47 00 00       	call   801050e6 <release>
801009af:	83 c4 10             	add    $0x10,%esp
  if(doprocdump) {
801009b2:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801009b6:	74 05                	je     801009bd <consoleintr+0x1a7>
    procdump();  // now call procdump() wo. cons.lock held
801009b8:	e8 6e 45 00 00       	call   80104f2b <procdump>
  }
}
801009bd:	90                   	nop
801009be:	c9                   	leave
801009bf:	c3                   	ret

801009c0 <consoleread>:

int
consoleread(struct inode *ip, char *dst, int n)
{
801009c0:	55                   	push   %ebp
801009c1:	89 e5                	mov    %esp,%ebp
801009c3:	83 ec 18             	sub    $0x18,%esp
  uint target;
  int c;

  iunlock(ip);
801009c6:	83 ec 0c             	sub    $0xc,%esp
801009c9:	ff 75 08             	push   0x8(%ebp)
801009cc:	e8 16 11 00 00       	call   80101ae7 <iunlock>
801009d1:	83 c4 10             	add    $0x10,%esp
  target = n;
801009d4:	8b 45 10             	mov    0x10(%ebp),%eax
801009d7:	89 45 f4             	mov    %eax,-0xc(%ebp)
  acquire(&cons.lock);
801009da:	83 ec 0c             	sub    $0xc,%esp
801009dd:	68 80 f7 10 80       	push   $0x8010f780
801009e2:	e8 98 46 00 00       	call   8010507f <acquire>
801009e7:	83 c4 10             	add    $0x10,%esp
  while(n > 0){
801009ea:	e9 ac 00 00 00       	jmp    80100a9b <consoleread+0xdb>
    while(input.r == input.w){
      if(proc->killed){
801009ef:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801009f5:	8b 40 24             	mov    0x24(%eax),%eax
801009f8:	85 c0                	test   %eax,%eax
801009fa:	74 28                	je     80100a24 <consoleread+0x64>
        release(&cons.lock);
801009fc:	83 ec 0c             	sub    $0xc,%esp
801009ff:	68 80 f7 10 80       	push   $0x8010f780
80100a04:	e8 dd 46 00 00       	call   801050e6 <release>
80100a09:	83 c4 10             	add    $0x10,%esp
        ilock(ip);
80100a0c:	83 ec 0c             	sub    $0xc,%esp
80100a0f:	ff 75 08             	push   0x8(%ebp)
80100a12:	e8 72 0f 00 00       	call   80101989 <ilock>
80100a17:	83 c4 10             	add    $0x10,%esp
        return -1;
80100a1a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80100a1f:	e9 ab 00 00 00       	jmp    80100acf <consoleread+0x10f>
      }
      sleep(&input.r, &cons.lock);
80100a24:	83 ec 08             	sub    $0x8,%esp
80100a27:	68 80 f7 10 80       	push   $0x8010f780
80100a2c:	68 60 f7 10 80       	push   $0x8010f760
80100a31:	e8 4e 43 00 00       	call   80104d84 <sleep>
80100a36:	83 c4 10             	add    $0x10,%esp
    while(input.r == input.w){
80100a39:	8b 15 60 f7 10 80    	mov    0x8010f760,%edx
80100a3f:	a1 64 f7 10 80       	mov    0x8010f764,%eax
80100a44:	39 c2                	cmp    %eax,%edx
80100a46:	74 a7                	je     801009ef <consoleread+0x2f>
    }
    c = input.buf[input.r++ % INPUT_BUF];
80100a48:	a1 60 f7 10 80       	mov    0x8010f760,%eax
80100a4d:	8d 50 01             	lea    0x1(%eax),%edx
80100a50:	89 15 60 f7 10 80    	mov    %edx,0x8010f760
80100a56:	83 e0 7f             	and    $0x7f,%eax
80100a59:	0f b6 80 e0 f6 10 80 	movzbl -0x7fef0920(%eax),%eax
80100a60:	0f be c0             	movsbl %al,%eax
80100a63:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(c == C('D')){  // EOF
80100a66:	83 7d f0 04          	cmpl   $0x4,-0x10(%ebp)
80100a6a:	75 17                	jne    80100a83 <consoleread+0xc3>
      if(n < target){
80100a6c:	8b 45 10             	mov    0x10(%ebp),%eax
80100a6f:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80100a72:	73 2f                	jae    80100aa3 <consoleread+0xe3>
        // Save ^D for next time, to make sure
        // caller gets a 0-byte result.
        input.r--;
80100a74:	a1 60 f7 10 80       	mov    0x8010f760,%eax
80100a79:	83 e8 01             	sub    $0x1,%eax
80100a7c:	a3 60 f7 10 80       	mov    %eax,0x8010f760
      }
      break;
80100a81:	eb 20                	jmp    80100aa3 <consoleread+0xe3>
    }
    *dst++ = c;
80100a83:	8b 45 0c             	mov    0xc(%ebp),%eax
80100a86:	8d 50 01             	lea    0x1(%eax),%edx
80100a89:	89 55 0c             	mov    %edx,0xc(%ebp)
80100a8c:	8b 55 f0             	mov    -0x10(%ebp),%edx
80100a8f:	88 10                	mov    %dl,(%eax)
    --n;
80100a91:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
    if(c == '\n')
80100a95:	83 7d f0 0a          	cmpl   $0xa,-0x10(%ebp)
80100a99:	74 0b                	je     80100aa6 <consoleread+0xe6>
  while(n > 0){
80100a9b:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80100a9f:	7f 98                	jg     80100a39 <consoleread+0x79>
80100aa1:	eb 04                	jmp    80100aa7 <consoleread+0xe7>
      break;
80100aa3:	90                   	nop
80100aa4:	eb 01                	jmp    80100aa7 <consoleread+0xe7>
      break;
80100aa6:	90                   	nop
  }
  release(&cons.lock);
80100aa7:	83 ec 0c             	sub    $0xc,%esp
80100aaa:	68 80 f7 10 80       	push   $0x8010f780
80100aaf:	e8 32 46 00 00       	call   801050e6 <release>
80100ab4:	83 c4 10             	add    $0x10,%esp
  ilock(ip);
80100ab7:	83 ec 0c             	sub    $0xc,%esp
80100aba:	ff 75 08             	push   0x8(%ebp)
80100abd:	e8 c7 0e 00 00       	call   80101989 <ilock>
80100ac2:	83 c4 10             	add    $0x10,%esp

  return target - n;
80100ac5:	8b 45 10             	mov    0x10(%ebp),%eax
80100ac8:	8b 55 f4             	mov    -0xc(%ebp),%edx
80100acb:	29 c2                	sub    %eax,%edx
80100acd:	89 d0                	mov    %edx,%eax
}
80100acf:	c9                   	leave
80100ad0:	c3                   	ret

80100ad1 <consolewrite>:

int
consolewrite(struct inode *ip, char *buf, int n)
{
80100ad1:	55                   	push   %ebp
80100ad2:	89 e5                	mov    %esp,%ebp
80100ad4:	83 ec 18             	sub    $0x18,%esp
  int i;

  iunlock(ip);
80100ad7:	83 ec 0c             	sub    $0xc,%esp
80100ada:	ff 75 08             	push   0x8(%ebp)
80100add:	e8 05 10 00 00       	call   80101ae7 <iunlock>
80100ae2:	83 c4 10             	add    $0x10,%esp
  acquire(&cons.lock);
80100ae5:	83 ec 0c             	sub    $0xc,%esp
80100ae8:	68 80 f7 10 80       	push   $0x8010f780
80100aed:	e8 8d 45 00 00       	call   8010507f <acquire>
80100af2:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < n; i++)
80100af5:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80100afc:	eb 21                	jmp    80100b1f <consolewrite+0x4e>
    consputc(buf[i] & 0xff);
80100afe:	8b 55 f4             	mov    -0xc(%ebp),%edx
80100b01:	8b 45 0c             	mov    0xc(%ebp),%eax
80100b04:	01 d0                	add    %edx,%eax
80100b06:	0f b6 00             	movzbl (%eax),%eax
80100b09:	0f be c0             	movsbl %al,%eax
80100b0c:	0f b6 c0             	movzbl %al,%eax
80100b0f:	83 ec 0c             	sub    $0xc,%esp
80100b12:	50                   	push   %eax
80100b13:	e8 96 fc ff ff       	call   801007ae <consputc>
80100b18:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < n; i++)
80100b1b:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80100b1f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100b22:	3b 45 10             	cmp    0x10(%ebp),%eax
80100b25:	7c d7                	jl     80100afe <consolewrite+0x2d>
  release(&cons.lock);
80100b27:	83 ec 0c             	sub    $0xc,%esp
80100b2a:	68 80 f7 10 80       	push   $0x8010f780
80100b2f:	e8 b2 45 00 00       	call   801050e6 <release>
80100b34:	83 c4 10             	add    $0x10,%esp
  ilock(ip);
80100b37:	83 ec 0c             	sub    $0xc,%esp
80100b3a:	ff 75 08             	push   0x8(%ebp)
80100b3d:	e8 47 0e 00 00       	call   80101989 <ilock>
80100b42:	83 c4 10             	add    $0x10,%esp

  return n;
80100b45:	8b 45 10             	mov    0x10(%ebp),%eax
}
80100b48:	c9                   	leave
80100b49:	c3                   	ret

80100b4a <consoleinit>:

void
consoleinit(void)
{
80100b4a:	55                   	push   %ebp
80100b4b:	89 e5                	mov    %esp,%ebp
80100b4d:	83 ec 08             	sub    $0x8,%esp
  initlock(&cons.lock, "console");
80100b50:	83 ec 08             	sub    $0x8,%esp
80100b53:	68 5e 88 10 80       	push   $0x8010885e
80100b58:	68 80 f7 10 80       	push   $0x8010f780
80100b5d:	e8 fb 44 00 00       	call   8010505d <initlock>
80100b62:	83 c4 10             	add    $0x10,%esp

  devsw[CONSOLE].write = consolewrite;
80100b65:	c7 05 cc f7 10 80 d1 	movl   $0x80100ad1,0x8010f7cc
80100b6c:	0a 10 80 
  devsw[CONSOLE].read = consoleread;
80100b6f:	c7 05 c8 f7 10 80 c0 	movl   $0x801009c0,0x8010f7c8
80100b76:	09 10 80 
  cons.locking = 1;
80100b79:	c7 05 b4 f7 10 80 01 	movl   $0x1,0x8010f7b4
80100b80:	00 00 00 

  picenable(IRQ_KBD);
80100b83:	83 ec 0c             	sub    $0xc,%esp
80100b86:	6a 01                	push   $0x1
80100b88:	e8 db 33 00 00       	call   80103f68 <picenable>
80100b8d:	83 c4 10             	add    $0x10,%esp
  ioapicenable(IRQ_KBD, 0);
80100b90:	83 ec 08             	sub    $0x8,%esp
80100b93:	6a 00                	push   $0x0
80100b95:	6a 01                	push   $0x1
80100b97:	e8 50 1f 00 00       	call   80102aec <ioapicenable>
80100b9c:	83 c4 10             	add    $0x10,%esp
}
80100b9f:	90                   	nop
80100ba0:	c9                   	leave
80100ba1:	c3                   	ret

80100ba2 <exec>:
#include "x86.h"
#include "elf.h"

int
exec(char *path, char **argv)
{
80100ba2:	55                   	push   %ebp
80100ba3:	89 e5                	mov    %esp,%ebp
80100ba5:	81 ec 18 01 00 00    	sub    $0x118,%esp
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pde_t *pgdir, *oldpgdir;

  begin_op();
80100bab:	e8 c0 29 00 00       	call   80103570 <begin_op>
  if((ip = namei(path)) == 0){
80100bb0:	83 ec 0c             	sub    $0xc,%esp
80100bb3:	ff 75 08             	push   0x8(%ebp)
80100bb6:	e8 7f 19 00 00       	call   8010253a <namei>
80100bbb:	83 c4 10             	add    $0x10,%esp
80100bbe:	89 45 d8             	mov    %eax,-0x28(%ebp)
80100bc1:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
80100bc5:	75 0f                	jne    80100bd6 <exec+0x34>
    end_op();
80100bc7:	e8 30 2a 00 00       	call   801035fc <end_op>
    return -1;
80100bcc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80100bd1:	e9 ce 03 00 00       	jmp    80100fa4 <exec+0x402>
  }
  ilock(ip);
80100bd6:	83 ec 0c             	sub    $0xc,%esp
80100bd9:	ff 75 d8             	push   -0x28(%ebp)
80100bdc:	e8 a8 0d 00 00       	call   80101989 <ilock>
80100be1:	83 c4 10             	add    $0x10,%esp
  pgdir = 0;
80100be4:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)

  // Check ELF header
  if(readi(ip, (char*)&elf, 0, sizeof(elf)) < sizeof(elf))
80100beb:	6a 34                	push   $0x34
80100bed:	6a 00                	push   $0x0
80100bef:	8d 85 0c ff ff ff    	lea    -0xf4(%ebp),%eax
80100bf5:	50                   	push   %eax
80100bf6:	ff 75 d8             	push   -0x28(%ebp)
80100bf9:	e8 f4 12 00 00       	call   80101ef2 <readi>
80100bfe:	83 c4 10             	add    $0x10,%esp
80100c01:	83 f8 33             	cmp    $0x33,%eax
80100c04:	0f 86 49 03 00 00    	jbe    80100f53 <exec+0x3b1>
    goto bad;
  if(elf.magic != ELF_MAGIC)
80100c0a:	8b 85 0c ff ff ff    	mov    -0xf4(%ebp),%eax
80100c10:	3d 7f 45 4c 46       	cmp    $0x464c457f,%eax
80100c15:	0f 85 3b 03 00 00    	jne    80100f56 <exec+0x3b4>
    goto bad;

  if((pgdir = setupkvm()) == 0)
80100c1b:	e8 c0 73 00 00       	call   80107fe0 <setupkvm>
80100c20:	89 45 d4             	mov    %eax,-0x2c(%ebp)
80100c23:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
80100c27:	0f 84 2c 03 00 00    	je     80100f59 <exec+0x3b7>
    goto bad;

  // Load program into memory.
  sz = 0;
80100c2d:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
80100c34:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
80100c3b:	8b 85 28 ff ff ff    	mov    -0xd8(%ebp),%eax
80100c41:	89 45 e8             	mov    %eax,-0x18(%ebp)
80100c44:	e9 ab 00 00 00       	jmp    80100cf4 <exec+0x152>
    if(readi(ip, (char*)&ph, off, sizeof(ph)) != sizeof(ph))
80100c49:	8b 45 e8             	mov    -0x18(%ebp),%eax
80100c4c:	6a 20                	push   $0x20
80100c4e:	50                   	push   %eax
80100c4f:	8d 85 ec fe ff ff    	lea    -0x114(%ebp),%eax
80100c55:	50                   	push   %eax
80100c56:	ff 75 d8             	push   -0x28(%ebp)
80100c59:	e8 94 12 00 00       	call   80101ef2 <readi>
80100c5e:	83 c4 10             	add    $0x10,%esp
80100c61:	83 f8 20             	cmp    $0x20,%eax
80100c64:	0f 85 f2 02 00 00    	jne    80100f5c <exec+0x3ba>
      goto bad;
    if(ph.type != ELF_PROG_LOAD)
80100c6a:	8b 85 ec fe ff ff    	mov    -0x114(%ebp),%eax
80100c70:	83 f8 01             	cmp    $0x1,%eax
80100c73:	75 71                	jne    80100ce6 <exec+0x144>
      continue;
    if(ph.memsz < ph.filesz)
80100c75:	8b 95 00 ff ff ff    	mov    -0x100(%ebp),%edx
80100c7b:	8b 85 fc fe ff ff    	mov    -0x104(%ebp),%eax
80100c81:	39 c2                	cmp    %eax,%edx
80100c83:	0f 82 d6 02 00 00    	jb     80100f5f <exec+0x3bd>
      goto bad;
    if((sz = allocuvm(pgdir, sz, ph.vaddr + ph.memsz)) == 0)
80100c89:	8b 95 f4 fe ff ff    	mov    -0x10c(%ebp),%edx
80100c8f:	8b 85 00 ff ff ff    	mov    -0x100(%ebp),%eax
80100c95:	01 d0                	add    %edx,%eax
80100c97:	83 ec 04             	sub    $0x4,%esp
80100c9a:	50                   	push   %eax
80100c9b:	ff 75 e0             	push   -0x20(%ebp)
80100c9e:	ff 75 d4             	push   -0x2c(%ebp)
80100ca1:	e8 e2 76 00 00       	call   80108388 <allocuvm>
80100ca6:	83 c4 10             	add    $0x10,%esp
80100ca9:	89 45 e0             	mov    %eax,-0x20(%ebp)
80100cac:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80100cb0:	0f 84 ac 02 00 00    	je     80100f62 <exec+0x3c0>
      goto bad;
    if(loaduvm(pgdir, (char*)ph.vaddr, ip, ph.off, ph.filesz) < 0)
80100cb6:	8b 95 fc fe ff ff    	mov    -0x104(%ebp),%edx
80100cbc:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
80100cc2:	8b 8d f4 fe ff ff    	mov    -0x10c(%ebp),%ecx
80100cc8:	83 ec 0c             	sub    $0xc,%esp
80100ccb:	52                   	push   %edx
80100ccc:	50                   	push   %eax
80100ccd:	ff 75 d8             	push   -0x28(%ebp)
80100cd0:	51                   	push   %ecx
80100cd1:	ff 75 d4             	push   -0x2c(%ebp)
80100cd4:	e8 d8 75 00 00       	call   801082b1 <loaduvm>
80100cd9:	83 c4 20             	add    $0x20,%esp
80100cdc:	85 c0                	test   %eax,%eax
80100cde:	0f 88 81 02 00 00    	js     80100f65 <exec+0x3c3>
80100ce4:	eb 01                	jmp    80100ce7 <exec+0x145>
      continue;
80100ce6:	90                   	nop
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
80100ce7:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
80100ceb:	8b 45 e8             	mov    -0x18(%ebp),%eax
80100cee:	83 c0 20             	add    $0x20,%eax
80100cf1:	89 45 e8             	mov    %eax,-0x18(%ebp)
80100cf4:	0f b7 85 38 ff ff ff 	movzwl -0xc8(%ebp),%eax
80100cfb:	0f b7 c0             	movzwl %ax,%eax
80100cfe:	39 45 ec             	cmp    %eax,-0x14(%ebp)
80100d01:	0f 8c 42 ff ff ff    	jl     80100c49 <exec+0xa7>
      goto bad;
  }
  iunlockput(ip);
80100d07:	83 ec 0c             	sub    $0xc,%esp
80100d0a:	ff 75 d8             	push   -0x28(%ebp)
80100d0d:	e8 37 0f 00 00       	call   80101c49 <iunlockput>
80100d12:	83 c4 10             	add    $0x10,%esp
  end_op();
80100d15:	e8 e2 28 00 00       	call   801035fc <end_op>
  ip = 0;
80100d1a:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)

  // Allocate two pages at the next page boundary.
  // Make the first inaccessible.  Use the second as the user stack.
  sz = PGROUNDUP(sz);
80100d21:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100d24:	05 ff 0f 00 00       	add    $0xfff,%eax
80100d29:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80100d2e:	89 45 e0             	mov    %eax,-0x20(%ebp)
  if((sz = allocuvm(pgdir, sz, sz + 2*PGSIZE)) == 0)
80100d31:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100d34:	05 00 20 00 00       	add    $0x2000,%eax
80100d39:	83 ec 04             	sub    $0x4,%esp
80100d3c:	50                   	push   %eax
80100d3d:	ff 75 e0             	push   -0x20(%ebp)
80100d40:	ff 75 d4             	push   -0x2c(%ebp)
80100d43:	e8 40 76 00 00       	call   80108388 <allocuvm>
80100d48:	83 c4 10             	add    $0x10,%esp
80100d4b:	89 45 e0             	mov    %eax,-0x20(%ebp)
80100d4e:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80100d52:	0f 84 10 02 00 00    	je     80100f68 <exec+0x3c6>
    goto bad;
  clearpteu(pgdir, (char*)(sz - 2*PGSIZE));
80100d58:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100d5b:	2d 00 20 00 00       	sub    $0x2000,%eax
80100d60:	83 ec 08             	sub    $0x8,%esp
80100d63:	50                   	push   %eax
80100d64:	ff 75 d4             	push   -0x2c(%ebp)
80100d67:	e8 40 78 00 00       	call   801085ac <clearpteu>
80100d6c:	83 c4 10             	add    $0x10,%esp
  sp = sz;
80100d6f:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100d72:	89 45 dc             	mov    %eax,-0x24(%ebp)

  // Push argument strings, prepare rest of stack in ustack.
  for(argc = 0; argv[argc]; argc++) {
80100d75:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
80100d7c:	e9 96 00 00 00       	jmp    80100e17 <exec+0x275>
    if(argc >= MAXARG)
80100d81:	83 7d e4 1f          	cmpl   $0x1f,-0x1c(%ebp)
80100d85:	0f 87 e0 01 00 00    	ja     80100f6b <exec+0x3c9>
      goto bad;
    sp = (sp - (strlen(argv[argc]) + 1)) & ~3;
80100d8b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100d8e:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100d95:	8b 45 0c             	mov    0xc(%ebp),%eax
80100d98:	01 d0                	add    %edx,%eax
80100d9a:	8b 00                	mov    (%eax),%eax
80100d9c:	83 ec 0c             	sub    $0xc,%esp
80100d9f:	50                   	push   %eax
80100da0:	e8 8c 47 00 00       	call   80105531 <strlen>
80100da5:	83 c4 10             	add    $0x10,%esp
80100da8:	89 c2                	mov    %eax,%edx
80100daa:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100dad:	29 d0                	sub    %edx,%eax
80100daf:	83 e8 01             	sub    $0x1,%eax
80100db2:	83 e0 fc             	and    $0xfffffffc,%eax
80100db5:	89 45 dc             	mov    %eax,-0x24(%ebp)
    if(copyout(pgdir, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
80100db8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100dbb:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100dc2:	8b 45 0c             	mov    0xc(%ebp),%eax
80100dc5:	01 d0                	add    %edx,%eax
80100dc7:	8b 00                	mov    (%eax),%eax
80100dc9:	83 ec 0c             	sub    $0xc,%esp
80100dcc:	50                   	push   %eax
80100dcd:	e8 5f 47 00 00       	call   80105531 <strlen>
80100dd2:	83 c4 10             	add    $0x10,%esp
80100dd5:	83 c0 01             	add    $0x1,%eax
80100dd8:	89 c1                	mov    %eax,%ecx
80100dda:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100ddd:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100de4:	8b 45 0c             	mov    0xc(%ebp),%eax
80100de7:	01 d0                	add    %edx,%eax
80100de9:	8b 00                	mov    (%eax),%eax
80100deb:	51                   	push   %ecx
80100dec:	50                   	push   %eax
80100ded:	ff 75 dc             	push   -0x24(%ebp)
80100df0:	ff 75 d4             	push   -0x2c(%ebp)
80100df3:	e8 6a 79 00 00       	call   80108762 <copyout>
80100df8:	83 c4 10             	add    $0x10,%esp
80100dfb:	85 c0                	test   %eax,%eax
80100dfd:	0f 88 6b 01 00 00    	js     80100f6e <exec+0x3cc>
      goto bad;
    ustack[3+argc] = sp;
80100e03:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e06:	8d 50 03             	lea    0x3(%eax),%edx
80100e09:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100e0c:	89 84 95 40 ff ff ff 	mov    %eax,-0xc0(%ebp,%edx,4)
  for(argc = 0; argv[argc]; argc++) {
80100e13:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
80100e17:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e1a:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100e21:	8b 45 0c             	mov    0xc(%ebp),%eax
80100e24:	01 d0                	add    %edx,%eax
80100e26:	8b 00                	mov    (%eax),%eax
80100e28:	85 c0                	test   %eax,%eax
80100e2a:	0f 85 51 ff ff ff    	jne    80100d81 <exec+0x1df>
  }
  ustack[3+argc] = 0;
80100e30:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e33:	83 c0 03             	add    $0x3,%eax
80100e36:	c7 84 85 40 ff ff ff 	movl   $0x0,-0xc0(%ebp,%eax,4)
80100e3d:	00 00 00 00 

  ustack[0] = 0xffffffff;  // fake return PC
80100e41:	c7 85 40 ff ff ff ff 	movl   $0xffffffff,-0xc0(%ebp)
80100e48:	ff ff ff 
  ustack[1] = argc;
80100e4b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e4e:	89 85 44 ff ff ff    	mov    %eax,-0xbc(%ebp)
  ustack[2] = sp - (argc+1)*4;  // argv pointer
80100e54:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e57:	83 c0 01             	add    $0x1,%eax
80100e5a:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100e61:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100e64:	29 d0                	sub    %edx,%eax
80100e66:	89 85 48 ff ff ff    	mov    %eax,-0xb8(%ebp)

  sp -= (3+argc+1) * 4;
80100e6c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e6f:	83 c0 04             	add    $0x4,%eax
80100e72:	c1 e0 02             	shl    $0x2,%eax
80100e75:	29 45 dc             	sub    %eax,-0x24(%ebp)
  if(copyout(pgdir, sp, ustack, (3+argc+1)*4) < 0)
80100e78:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e7b:	83 c0 04             	add    $0x4,%eax
80100e7e:	c1 e0 02             	shl    $0x2,%eax
80100e81:	50                   	push   %eax
80100e82:	8d 85 40 ff ff ff    	lea    -0xc0(%ebp),%eax
80100e88:	50                   	push   %eax
80100e89:	ff 75 dc             	push   -0x24(%ebp)
80100e8c:	ff 75 d4             	push   -0x2c(%ebp)
80100e8f:	e8 ce 78 00 00       	call   80108762 <copyout>
80100e94:	83 c4 10             	add    $0x10,%esp
80100e97:	85 c0                	test   %eax,%eax
80100e99:	0f 88 d2 00 00 00    	js     80100f71 <exec+0x3cf>
    goto bad;

  // Save program name for debugging.
  for(last=s=path; *s; s++)
80100e9f:	8b 45 08             	mov    0x8(%ebp),%eax
80100ea2:	89 45 f4             	mov    %eax,-0xc(%ebp)
80100ea5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100ea8:	89 45 f0             	mov    %eax,-0x10(%ebp)
80100eab:	eb 17                	jmp    80100ec4 <exec+0x322>
    if(*s == '/')
80100ead:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100eb0:	0f b6 00             	movzbl (%eax),%eax
80100eb3:	3c 2f                	cmp    $0x2f,%al
80100eb5:	75 09                	jne    80100ec0 <exec+0x31e>
      last = s+1;
80100eb7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100eba:	83 c0 01             	add    $0x1,%eax
80100ebd:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(last=s=path; *s; s++)
80100ec0:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80100ec4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100ec7:	0f b6 00             	movzbl (%eax),%eax
80100eca:	84 c0                	test   %al,%al
80100ecc:	75 df                	jne    80100ead <exec+0x30b>
  safestrcpy(proc->name, last, sizeof(proc->name));
80100ece:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100ed4:	83 c0 6c             	add    $0x6c,%eax
80100ed7:	83 ec 04             	sub    $0x4,%esp
80100eda:	6a 10                	push   $0x10
80100edc:	ff 75 f0             	push   -0x10(%ebp)
80100edf:	50                   	push   %eax
80100ee0:	e8 01 46 00 00       	call   801054e6 <safestrcpy>
80100ee5:	83 c4 10             	add    $0x10,%esp

  // Commit to the user image.
  oldpgdir = proc->pgdir;
80100ee8:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100eee:	8b 40 04             	mov    0x4(%eax),%eax
80100ef1:	89 45 d0             	mov    %eax,-0x30(%ebp)
  proc->pgdir = pgdir;
80100ef4:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100efa:	8b 55 d4             	mov    -0x2c(%ebp),%edx
80100efd:	89 50 04             	mov    %edx,0x4(%eax)
  proc->sz = sz;
80100f00:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100f06:	8b 55 e0             	mov    -0x20(%ebp),%edx
80100f09:	89 10                	mov    %edx,(%eax)
  proc->tf->eip = elf.entry;  // main
80100f0b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100f11:	8b 40 18             	mov    0x18(%eax),%eax
80100f14:	8b 95 24 ff ff ff    	mov    -0xdc(%ebp),%edx
80100f1a:	89 50 38             	mov    %edx,0x38(%eax)
  proc->tf->esp = sp;
80100f1d:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100f23:	8b 40 18             	mov    0x18(%eax),%eax
80100f26:	8b 55 dc             	mov    -0x24(%ebp),%edx
80100f29:	89 50 44             	mov    %edx,0x44(%eax)
  switchuvm(proc);
80100f2c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100f32:	83 ec 0c             	sub    $0xc,%esp
80100f35:	50                   	push   %eax
80100f36:	e8 8c 71 00 00       	call   801080c7 <switchuvm>
80100f3b:	83 c4 10             	add    $0x10,%esp
  freevm(oldpgdir);
80100f3e:	83 ec 0c             	sub    $0xc,%esp
80100f41:	ff 75 d0             	push   -0x30(%ebp)
80100f44:	e8 c3 75 00 00       	call   8010850c <freevm>
80100f49:	83 c4 10             	add    $0x10,%esp
  return 0;
80100f4c:	b8 00 00 00 00       	mov    $0x0,%eax
80100f51:	eb 51                	jmp    80100fa4 <exec+0x402>
    goto bad;
80100f53:	90                   	nop
80100f54:	eb 1c                	jmp    80100f72 <exec+0x3d0>
    goto bad;
80100f56:	90                   	nop
80100f57:	eb 19                	jmp    80100f72 <exec+0x3d0>
    goto bad;
80100f59:	90                   	nop
80100f5a:	eb 16                	jmp    80100f72 <exec+0x3d0>
      goto bad;
80100f5c:	90                   	nop
80100f5d:	eb 13                	jmp    80100f72 <exec+0x3d0>
      goto bad;
80100f5f:	90                   	nop
80100f60:	eb 10                	jmp    80100f72 <exec+0x3d0>
      goto bad;
80100f62:	90                   	nop
80100f63:	eb 0d                	jmp    80100f72 <exec+0x3d0>
      goto bad;
80100f65:	90                   	nop
80100f66:	eb 0a                	jmp    80100f72 <exec+0x3d0>
    goto bad;
80100f68:	90                   	nop
80100f69:	eb 07                	jmp    80100f72 <exec+0x3d0>
      goto bad;
80100f6b:	90                   	nop
80100f6c:	eb 04                	jmp    80100f72 <exec+0x3d0>
      goto bad;
80100f6e:	90                   	nop
80100f6f:	eb 01                	jmp    80100f72 <exec+0x3d0>
    goto bad;
80100f71:	90                   	nop

 bad:
  if(pgdir)
80100f72:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
80100f76:	74 0e                	je     80100f86 <exec+0x3e4>
    freevm(pgdir);
80100f78:	83 ec 0c             	sub    $0xc,%esp
80100f7b:	ff 75 d4             	push   -0x2c(%ebp)
80100f7e:	e8 89 75 00 00       	call   8010850c <freevm>
80100f83:	83 c4 10             	add    $0x10,%esp
  if(ip){
80100f86:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
80100f8a:	74 13                	je     80100f9f <exec+0x3fd>
    iunlockput(ip);
80100f8c:	83 ec 0c             	sub    $0xc,%esp
80100f8f:	ff 75 d8             	push   -0x28(%ebp)
80100f92:	e8 b2 0c 00 00       	call   80101c49 <iunlockput>
80100f97:	83 c4 10             	add    $0x10,%esp
    end_op();
80100f9a:	e8 5d 26 00 00       	call   801035fc <end_op>
  }
  return -1;
80100f9f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80100fa4:	c9                   	leave
80100fa5:	c3                   	ret

80100fa6 <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
80100fa6:	55                   	push   %ebp
80100fa7:	89 e5                	mov    %esp,%ebp
80100fa9:	83 ec 08             	sub    $0x8,%esp
  initlock(&ftable.lock, "ftable");
80100fac:	83 ec 08             	sub    $0x8,%esp
80100faf:	68 66 88 10 80       	push   $0x80108866
80100fb4:	68 20 f8 10 80       	push   $0x8010f820
80100fb9:	e8 9f 40 00 00       	call   8010505d <initlock>
80100fbe:	83 c4 10             	add    $0x10,%esp
}
80100fc1:	90                   	nop
80100fc2:	c9                   	leave
80100fc3:	c3                   	ret

80100fc4 <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
80100fc4:	55                   	push   %ebp
80100fc5:	89 e5                	mov    %esp,%ebp
80100fc7:	83 ec 18             	sub    $0x18,%esp
  struct file *f;

  acquire(&ftable.lock);
80100fca:	83 ec 0c             	sub    $0xc,%esp
80100fcd:	68 20 f8 10 80       	push   $0x8010f820
80100fd2:	e8 a8 40 00 00       	call   8010507f <acquire>
80100fd7:	83 c4 10             	add    $0x10,%esp
  for(f = ftable.file; f < ftable.file + NFILE; f++){
80100fda:	c7 45 f4 54 f8 10 80 	movl   $0x8010f854,-0xc(%ebp)
80100fe1:	eb 2d                	jmp    80101010 <filealloc+0x4c>
    if(f->ref == 0){
80100fe3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100fe6:	8b 40 04             	mov    0x4(%eax),%eax
80100fe9:	85 c0                	test   %eax,%eax
80100feb:	75 1f                	jne    8010100c <filealloc+0x48>
      f->ref = 1;
80100fed:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100ff0:	c7 40 04 01 00 00 00 	movl   $0x1,0x4(%eax)
      release(&ftable.lock);
80100ff7:	83 ec 0c             	sub    $0xc,%esp
80100ffa:	68 20 f8 10 80       	push   $0x8010f820
80100fff:	e8 e2 40 00 00       	call   801050e6 <release>
80101004:	83 c4 10             	add    $0x10,%esp
      return f;
80101007:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010100a:	eb 23                	jmp    8010102f <filealloc+0x6b>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
8010100c:	83 45 f4 18          	addl   $0x18,-0xc(%ebp)
80101010:	b8 b4 01 11 80       	mov    $0x801101b4,%eax
80101015:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80101018:	72 c9                	jb     80100fe3 <filealloc+0x1f>
    }
  }
  release(&ftable.lock);
8010101a:	83 ec 0c             	sub    $0xc,%esp
8010101d:	68 20 f8 10 80       	push   $0x8010f820
80101022:	e8 bf 40 00 00       	call   801050e6 <release>
80101027:	83 c4 10             	add    $0x10,%esp
  return 0;
8010102a:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010102f:	c9                   	leave
80101030:	c3                   	ret

80101031 <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
80101031:	55                   	push   %ebp
80101032:	89 e5                	mov    %esp,%ebp
80101034:	83 ec 08             	sub    $0x8,%esp
  acquire(&ftable.lock);
80101037:	83 ec 0c             	sub    $0xc,%esp
8010103a:	68 20 f8 10 80       	push   $0x8010f820
8010103f:	e8 3b 40 00 00       	call   8010507f <acquire>
80101044:	83 c4 10             	add    $0x10,%esp
  if(f->ref < 1)
80101047:	8b 45 08             	mov    0x8(%ebp),%eax
8010104a:	8b 40 04             	mov    0x4(%eax),%eax
8010104d:	85 c0                	test   %eax,%eax
8010104f:	7f 0d                	jg     8010105e <filedup+0x2d>
    panic("filedup");
80101051:	83 ec 0c             	sub    $0xc,%esp
80101054:	68 6d 88 10 80       	push   $0x8010886d
80101059:	e8 1b f5 ff ff       	call   80100579 <panic>
  f->ref++;
8010105e:	8b 45 08             	mov    0x8(%ebp),%eax
80101061:	8b 40 04             	mov    0x4(%eax),%eax
80101064:	8d 50 01             	lea    0x1(%eax),%edx
80101067:	8b 45 08             	mov    0x8(%ebp),%eax
8010106a:	89 50 04             	mov    %edx,0x4(%eax)
  release(&ftable.lock);
8010106d:	83 ec 0c             	sub    $0xc,%esp
80101070:	68 20 f8 10 80       	push   $0x8010f820
80101075:	e8 6c 40 00 00       	call   801050e6 <release>
8010107a:	83 c4 10             	add    $0x10,%esp
  return f;
8010107d:	8b 45 08             	mov    0x8(%ebp),%eax
}
80101080:	c9                   	leave
80101081:	c3                   	ret

80101082 <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
80101082:	55                   	push   %ebp
80101083:	89 e5                	mov    %esp,%ebp
80101085:	83 ec 28             	sub    $0x28,%esp
  struct file ff;

  acquire(&ftable.lock);
80101088:	83 ec 0c             	sub    $0xc,%esp
8010108b:	68 20 f8 10 80       	push   $0x8010f820
80101090:	e8 ea 3f 00 00       	call   8010507f <acquire>
80101095:	83 c4 10             	add    $0x10,%esp
  if(f->ref < 1)
80101098:	8b 45 08             	mov    0x8(%ebp),%eax
8010109b:	8b 40 04             	mov    0x4(%eax),%eax
8010109e:	85 c0                	test   %eax,%eax
801010a0:	7f 0d                	jg     801010af <fileclose+0x2d>
    panic("fileclose");
801010a2:	83 ec 0c             	sub    $0xc,%esp
801010a5:	68 75 88 10 80       	push   $0x80108875
801010aa:	e8 ca f4 ff ff       	call   80100579 <panic>
  if(--f->ref > 0){
801010af:	8b 45 08             	mov    0x8(%ebp),%eax
801010b2:	8b 40 04             	mov    0x4(%eax),%eax
801010b5:	8d 50 ff             	lea    -0x1(%eax),%edx
801010b8:	8b 45 08             	mov    0x8(%ebp),%eax
801010bb:	89 50 04             	mov    %edx,0x4(%eax)
801010be:	8b 45 08             	mov    0x8(%ebp),%eax
801010c1:	8b 40 04             	mov    0x4(%eax),%eax
801010c4:	85 c0                	test   %eax,%eax
801010c6:	7e 15                	jle    801010dd <fileclose+0x5b>
    release(&ftable.lock);
801010c8:	83 ec 0c             	sub    $0xc,%esp
801010cb:	68 20 f8 10 80       	push   $0x8010f820
801010d0:	e8 11 40 00 00       	call   801050e6 <release>
801010d5:	83 c4 10             	add    $0x10,%esp
801010d8:	e9 8b 00 00 00       	jmp    80101168 <fileclose+0xe6>
    return;
  }
  ff = *f;
801010dd:	8b 45 08             	mov    0x8(%ebp),%eax
801010e0:	8b 10                	mov    (%eax),%edx
801010e2:	89 55 e0             	mov    %edx,-0x20(%ebp)
801010e5:	8b 50 04             	mov    0x4(%eax),%edx
801010e8:	89 55 e4             	mov    %edx,-0x1c(%ebp)
801010eb:	8b 50 08             	mov    0x8(%eax),%edx
801010ee:	89 55 e8             	mov    %edx,-0x18(%ebp)
801010f1:	8b 50 0c             	mov    0xc(%eax),%edx
801010f4:	89 55 ec             	mov    %edx,-0x14(%ebp)
801010f7:	8b 50 10             	mov    0x10(%eax),%edx
801010fa:	89 55 f0             	mov    %edx,-0x10(%ebp)
801010fd:	8b 40 14             	mov    0x14(%eax),%eax
80101100:	89 45 f4             	mov    %eax,-0xc(%ebp)
  f->ref = 0;
80101103:	8b 45 08             	mov    0x8(%ebp),%eax
80101106:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
  f->type = FD_NONE;
8010110d:	8b 45 08             	mov    0x8(%ebp),%eax
80101110:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  release(&ftable.lock);
80101116:	83 ec 0c             	sub    $0xc,%esp
80101119:	68 20 f8 10 80       	push   $0x8010f820
8010111e:	e8 c3 3f 00 00       	call   801050e6 <release>
80101123:	83 c4 10             	add    $0x10,%esp
  
  if(ff.type == FD_PIPE)
80101126:	8b 45 e0             	mov    -0x20(%ebp),%eax
80101129:	83 f8 01             	cmp    $0x1,%eax
8010112c:	75 19                	jne    80101147 <fileclose+0xc5>
    pipeclose(ff.pipe, ff.writable);
8010112e:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
80101132:	0f be d0             	movsbl %al,%edx
80101135:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101138:	83 ec 08             	sub    $0x8,%esp
8010113b:	52                   	push   %edx
8010113c:	50                   	push   %eax
8010113d:	e8 8e 30 00 00       	call   801041d0 <pipeclose>
80101142:	83 c4 10             	add    $0x10,%esp
80101145:	eb 21                	jmp    80101168 <fileclose+0xe6>
  else if(ff.type == FD_INODE){
80101147:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010114a:	83 f8 02             	cmp    $0x2,%eax
8010114d:	75 19                	jne    80101168 <fileclose+0xe6>
    begin_op();
8010114f:	e8 1c 24 00 00       	call   80103570 <begin_op>
    iput(ff.ip);
80101154:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101157:	83 ec 0c             	sub    $0xc,%esp
8010115a:	50                   	push   %eax
8010115b:	e8 f9 09 00 00       	call   80101b59 <iput>
80101160:	83 c4 10             	add    $0x10,%esp
    end_op();
80101163:	e8 94 24 00 00       	call   801035fc <end_op>
  }
}
80101168:	c9                   	leave
80101169:	c3                   	ret

8010116a <filestat>:

// Get metadata about file f.
int
filestat(struct file *f, struct stat *st)
{
8010116a:	55                   	push   %ebp
8010116b:	89 e5                	mov    %esp,%ebp
8010116d:	83 ec 08             	sub    $0x8,%esp
  if(f->type == FD_INODE){
80101170:	8b 45 08             	mov    0x8(%ebp),%eax
80101173:	8b 00                	mov    (%eax),%eax
80101175:	83 f8 02             	cmp    $0x2,%eax
80101178:	75 40                	jne    801011ba <filestat+0x50>
    ilock(f->ip);
8010117a:	8b 45 08             	mov    0x8(%ebp),%eax
8010117d:	8b 40 10             	mov    0x10(%eax),%eax
80101180:	83 ec 0c             	sub    $0xc,%esp
80101183:	50                   	push   %eax
80101184:	e8 00 08 00 00       	call   80101989 <ilock>
80101189:	83 c4 10             	add    $0x10,%esp
    stati(f->ip, st);
8010118c:	8b 45 08             	mov    0x8(%ebp),%eax
8010118f:	8b 40 10             	mov    0x10(%eax),%eax
80101192:	83 ec 08             	sub    $0x8,%esp
80101195:	ff 75 0c             	push   0xc(%ebp)
80101198:	50                   	push   %eax
80101199:	e8 0e 0d 00 00       	call   80101eac <stati>
8010119e:	83 c4 10             	add    $0x10,%esp
    iunlock(f->ip);
801011a1:	8b 45 08             	mov    0x8(%ebp),%eax
801011a4:	8b 40 10             	mov    0x10(%eax),%eax
801011a7:	83 ec 0c             	sub    $0xc,%esp
801011aa:	50                   	push   %eax
801011ab:	e8 37 09 00 00       	call   80101ae7 <iunlock>
801011b0:	83 c4 10             	add    $0x10,%esp
    return 0;
801011b3:	b8 00 00 00 00       	mov    $0x0,%eax
801011b8:	eb 05                	jmp    801011bf <filestat+0x55>
  }
  return -1;
801011ba:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801011bf:	c9                   	leave
801011c0:	c3                   	ret

801011c1 <fileread>:

// Read from file f.
int
fileread(struct file *f, char *addr, int n)
{
801011c1:	55                   	push   %ebp
801011c2:	89 e5                	mov    %esp,%ebp
801011c4:	83 ec 18             	sub    $0x18,%esp
  int r;

  if(f->readable == 0)
801011c7:	8b 45 08             	mov    0x8(%ebp),%eax
801011ca:	0f b6 40 08          	movzbl 0x8(%eax),%eax
801011ce:	84 c0                	test   %al,%al
801011d0:	75 0a                	jne    801011dc <fileread+0x1b>
    return -1;
801011d2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801011d7:	e9 9b 00 00 00       	jmp    80101277 <fileread+0xb6>
  if(f->type == FD_PIPE)
801011dc:	8b 45 08             	mov    0x8(%ebp),%eax
801011df:	8b 00                	mov    (%eax),%eax
801011e1:	83 f8 01             	cmp    $0x1,%eax
801011e4:	75 1a                	jne    80101200 <fileread+0x3f>
    return piperead(f->pipe, addr, n);
801011e6:	8b 45 08             	mov    0x8(%ebp),%eax
801011e9:	8b 40 0c             	mov    0xc(%eax),%eax
801011ec:	83 ec 04             	sub    $0x4,%esp
801011ef:	ff 75 10             	push   0x10(%ebp)
801011f2:	ff 75 0c             	push   0xc(%ebp)
801011f5:	50                   	push   %eax
801011f6:	e8 83 31 00 00       	call   8010437e <piperead>
801011fb:	83 c4 10             	add    $0x10,%esp
801011fe:	eb 77                	jmp    80101277 <fileread+0xb6>
  if(f->type == FD_INODE){
80101200:	8b 45 08             	mov    0x8(%ebp),%eax
80101203:	8b 00                	mov    (%eax),%eax
80101205:	83 f8 02             	cmp    $0x2,%eax
80101208:	75 60                	jne    8010126a <fileread+0xa9>
    ilock(f->ip);
8010120a:	8b 45 08             	mov    0x8(%ebp),%eax
8010120d:	8b 40 10             	mov    0x10(%eax),%eax
80101210:	83 ec 0c             	sub    $0xc,%esp
80101213:	50                   	push   %eax
80101214:	e8 70 07 00 00       	call   80101989 <ilock>
80101219:	83 c4 10             	add    $0x10,%esp
    if((r = readi(f->ip, addr, f->off, n)) > 0)
8010121c:	8b 4d 10             	mov    0x10(%ebp),%ecx
8010121f:	8b 45 08             	mov    0x8(%ebp),%eax
80101222:	8b 50 14             	mov    0x14(%eax),%edx
80101225:	8b 45 08             	mov    0x8(%ebp),%eax
80101228:	8b 40 10             	mov    0x10(%eax),%eax
8010122b:	51                   	push   %ecx
8010122c:	52                   	push   %edx
8010122d:	ff 75 0c             	push   0xc(%ebp)
80101230:	50                   	push   %eax
80101231:	e8 bc 0c 00 00       	call   80101ef2 <readi>
80101236:	83 c4 10             	add    $0x10,%esp
80101239:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010123c:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101240:	7e 11                	jle    80101253 <fileread+0x92>
      f->off += r;
80101242:	8b 45 08             	mov    0x8(%ebp),%eax
80101245:	8b 50 14             	mov    0x14(%eax),%edx
80101248:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010124b:	01 c2                	add    %eax,%edx
8010124d:	8b 45 08             	mov    0x8(%ebp),%eax
80101250:	89 50 14             	mov    %edx,0x14(%eax)
    iunlock(f->ip);
80101253:	8b 45 08             	mov    0x8(%ebp),%eax
80101256:	8b 40 10             	mov    0x10(%eax),%eax
80101259:	83 ec 0c             	sub    $0xc,%esp
8010125c:	50                   	push   %eax
8010125d:	e8 85 08 00 00       	call   80101ae7 <iunlock>
80101262:	83 c4 10             	add    $0x10,%esp
    return r;
80101265:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101268:	eb 0d                	jmp    80101277 <fileread+0xb6>
  }
  panic("fileread");
8010126a:	83 ec 0c             	sub    $0xc,%esp
8010126d:	68 7f 88 10 80       	push   $0x8010887f
80101272:	e8 02 f3 ff ff       	call   80100579 <panic>
}
80101277:	c9                   	leave
80101278:	c3                   	ret

80101279 <filewrite>:

//PAGEBREAK!
// Write to file f.
int
filewrite(struct file *f, char *addr, int n)
{
80101279:	55                   	push   %ebp
8010127a:	89 e5                	mov    %esp,%ebp
8010127c:	53                   	push   %ebx
8010127d:	83 ec 14             	sub    $0x14,%esp
  int r;

  if(f->writable == 0)
80101280:	8b 45 08             	mov    0x8(%ebp),%eax
80101283:	0f b6 40 09          	movzbl 0x9(%eax),%eax
80101287:	84 c0                	test   %al,%al
80101289:	75 0a                	jne    80101295 <filewrite+0x1c>
    return -1;
8010128b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101290:	e9 1b 01 00 00       	jmp    801013b0 <filewrite+0x137>
  if(f->type == FD_PIPE)
80101295:	8b 45 08             	mov    0x8(%ebp),%eax
80101298:	8b 00                	mov    (%eax),%eax
8010129a:	83 f8 01             	cmp    $0x1,%eax
8010129d:	75 1d                	jne    801012bc <filewrite+0x43>
    return pipewrite(f->pipe, addr, n);
8010129f:	8b 45 08             	mov    0x8(%ebp),%eax
801012a2:	8b 40 0c             	mov    0xc(%eax),%eax
801012a5:	83 ec 04             	sub    $0x4,%esp
801012a8:	ff 75 10             	push   0x10(%ebp)
801012ab:	ff 75 0c             	push   0xc(%ebp)
801012ae:	50                   	push   %eax
801012af:	e8 c7 2f 00 00       	call   8010427b <pipewrite>
801012b4:	83 c4 10             	add    $0x10,%esp
801012b7:	e9 f4 00 00 00       	jmp    801013b0 <filewrite+0x137>
  if(f->type == FD_INODE){
801012bc:	8b 45 08             	mov    0x8(%ebp),%eax
801012bf:	8b 00                	mov    (%eax),%eax
801012c1:	83 f8 02             	cmp    $0x2,%eax
801012c4:	0f 85 d9 00 00 00    	jne    801013a3 <filewrite+0x12a>
    // the maximum log transaction size, including
    // i-node, indirect block, allocation blocks,
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((LOGSIZE-1-1-2) / 2) * 512;
801012ca:	c7 45 ec 00 1a 00 00 	movl   $0x1a00,-0x14(%ebp)
    int i = 0;
801012d1:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    while(i < n){
801012d8:	e9 a3 00 00 00       	jmp    80101380 <filewrite+0x107>
      int n1 = n - i;
801012dd:	8b 45 10             	mov    0x10(%ebp),%eax
801012e0:	2b 45 f4             	sub    -0xc(%ebp),%eax
801012e3:	89 45 f0             	mov    %eax,-0x10(%ebp)
      if(n1 > max)
801012e6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801012e9:	3b 45 ec             	cmp    -0x14(%ebp),%eax
801012ec:	7e 06                	jle    801012f4 <filewrite+0x7b>
        n1 = max;
801012ee:	8b 45 ec             	mov    -0x14(%ebp),%eax
801012f1:	89 45 f0             	mov    %eax,-0x10(%ebp)

      begin_op();
801012f4:	e8 77 22 00 00       	call   80103570 <begin_op>
      ilock(f->ip);
801012f9:	8b 45 08             	mov    0x8(%ebp),%eax
801012fc:	8b 40 10             	mov    0x10(%eax),%eax
801012ff:	83 ec 0c             	sub    $0xc,%esp
80101302:	50                   	push   %eax
80101303:	e8 81 06 00 00       	call   80101989 <ilock>
80101308:	83 c4 10             	add    $0x10,%esp
      if ((r = writei(f->ip, addr + i, f->off, n1)) > 0)
8010130b:	8b 4d f0             	mov    -0x10(%ebp),%ecx
8010130e:	8b 45 08             	mov    0x8(%ebp),%eax
80101311:	8b 50 14             	mov    0x14(%eax),%edx
80101314:	8b 5d f4             	mov    -0xc(%ebp),%ebx
80101317:	8b 45 0c             	mov    0xc(%ebp),%eax
8010131a:	01 c3                	add    %eax,%ebx
8010131c:	8b 45 08             	mov    0x8(%ebp),%eax
8010131f:	8b 40 10             	mov    0x10(%eax),%eax
80101322:	51                   	push   %ecx
80101323:	52                   	push   %edx
80101324:	53                   	push   %ebx
80101325:	50                   	push   %eax
80101326:	e8 1c 0d 00 00       	call   80102047 <writei>
8010132b:	83 c4 10             	add    $0x10,%esp
8010132e:	89 45 e8             	mov    %eax,-0x18(%ebp)
80101331:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
80101335:	7e 11                	jle    80101348 <filewrite+0xcf>
        f->off += r;
80101337:	8b 45 08             	mov    0x8(%ebp),%eax
8010133a:	8b 50 14             	mov    0x14(%eax),%edx
8010133d:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101340:	01 c2                	add    %eax,%edx
80101342:	8b 45 08             	mov    0x8(%ebp),%eax
80101345:	89 50 14             	mov    %edx,0x14(%eax)
      iunlock(f->ip);
80101348:	8b 45 08             	mov    0x8(%ebp),%eax
8010134b:	8b 40 10             	mov    0x10(%eax),%eax
8010134e:	83 ec 0c             	sub    $0xc,%esp
80101351:	50                   	push   %eax
80101352:	e8 90 07 00 00       	call   80101ae7 <iunlock>
80101357:	83 c4 10             	add    $0x10,%esp
      end_op();
8010135a:	e8 9d 22 00 00       	call   801035fc <end_op>

      if(r < 0)
8010135f:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
80101363:	78 29                	js     8010138e <filewrite+0x115>
        break;
      if(r != n1)
80101365:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101368:	3b 45 f0             	cmp    -0x10(%ebp),%eax
8010136b:	74 0d                	je     8010137a <filewrite+0x101>
        panic("short filewrite");
8010136d:	83 ec 0c             	sub    $0xc,%esp
80101370:	68 88 88 10 80       	push   $0x80108888
80101375:	e8 ff f1 ff ff       	call   80100579 <panic>
      i += r;
8010137a:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010137d:	01 45 f4             	add    %eax,-0xc(%ebp)
    while(i < n){
80101380:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101383:	3b 45 10             	cmp    0x10(%ebp),%eax
80101386:	0f 8c 51 ff ff ff    	jl     801012dd <filewrite+0x64>
8010138c:	eb 01                	jmp    8010138f <filewrite+0x116>
        break;
8010138e:	90                   	nop
    }
    return i == n ? n : -1;
8010138f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101392:	3b 45 10             	cmp    0x10(%ebp),%eax
80101395:	75 05                	jne    8010139c <filewrite+0x123>
80101397:	8b 45 10             	mov    0x10(%ebp),%eax
8010139a:	eb 14                	jmp    801013b0 <filewrite+0x137>
8010139c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801013a1:	eb 0d                	jmp    801013b0 <filewrite+0x137>
  }
  panic("filewrite");
801013a3:	83 ec 0c             	sub    $0xc,%esp
801013a6:	68 98 88 10 80       	push   $0x80108898
801013ab:	e8 c9 f1 ff ff       	call   80100579 <panic>
}
801013b0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801013b3:	c9                   	leave
801013b4:	c3                   	ret

801013b5 <readsb>:
struct superblock sb;   // there should be one per dev, but we run with one dev

// Read the super block.
void
readsb(int dev, struct superblock *sb)
{
801013b5:	55                   	push   %ebp
801013b6:	89 e5                	mov    %esp,%ebp
801013b8:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;
  
  bp = bread(dev, 1);
801013bb:	8b 45 08             	mov    0x8(%ebp),%eax
801013be:	83 ec 08             	sub    $0x8,%esp
801013c1:	6a 01                	push   $0x1
801013c3:	50                   	push   %eax
801013c4:	e8 ee ed ff ff       	call   801001b7 <bread>
801013c9:	83 c4 10             	add    $0x10,%esp
801013cc:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memmove(sb, bp->data, sizeof(*sb));
801013cf:	8b 45 f4             	mov    -0xc(%ebp),%eax
801013d2:	83 c0 18             	add    $0x18,%eax
801013d5:	83 ec 04             	sub    $0x4,%esp
801013d8:	6a 1c                	push   $0x1c
801013da:	50                   	push   %eax
801013db:	ff 75 0c             	push   0xc(%ebp)
801013de:	e8 bf 3f 00 00       	call   801053a2 <memmove>
801013e3:	83 c4 10             	add    $0x10,%esp
  brelse(bp);
801013e6:	83 ec 0c             	sub    $0xc,%esp
801013e9:	ff 75 f4             	push   -0xc(%ebp)
801013ec:	e8 3e ee ff ff       	call   8010022f <brelse>
801013f1:	83 c4 10             	add    $0x10,%esp
}
801013f4:	90                   	nop
801013f5:	c9                   	leave
801013f6:	c3                   	ret

801013f7 <bzero>:

// Zero a block.
static void
bzero(int dev, int bno)
{
801013f7:	55                   	push   %ebp
801013f8:	89 e5                	mov    %esp,%ebp
801013fa:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;
  
  bp = bread(dev, bno);
801013fd:	8b 55 0c             	mov    0xc(%ebp),%edx
80101400:	8b 45 08             	mov    0x8(%ebp),%eax
80101403:	83 ec 08             	sub    $0x8,%esp
80101406:	52                   	push   %edx
80101407:	50                   	push   %eax
80101408:	e8 aa ed ff ff       	call   801001b7 <bread>
8010140d:	83 c4 10             	add    $0x10,%esp
80101410:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(bp->data, 0, BSIZE);
80101413:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101416:	83 c0 18             	add    $0x18,%eax
80101419:	83 ec 04             	sub    $0x4,%esp
8010141c:	68 00 02 00 00       	push   $0x200
80101421:	6a 00                	push   $0x0
80101423:	50                   	push   %eax
80101424:	e8 ba 3e 00 00       	call   801052e3 <memset>
80101429:	83 c4 10             	add    $0x10,%esp
  log_write(bp);
8010142c:	83 ec 0c             	sub    $0xc,%esp
8010142f:	ff 75 f4             	push   -0xc(%ebp)
80101432:	e8 72 23 00 00       	call   801037a9 <log_write>
80101437:	83 c4 10             	add    $0x10,%esp
  brelse(bp);
8010143a:	83 ec 0c             	sub    $0xc,%esp
8010143d:	ff 75 f4             	push   -0xc(%ebp)
80101440:	e8 ea ed ff ff       	call   8010022f <brelse>
80101445:	83 c4 10             	add    $0x10,%esp
}
80101448:	90                   	nop
80101449:	c9                   	leave
8010144a:	c3                   	ret

8010144b <balloc>:
// Blocks. 

// Allocate a zeroed disk block.
static uint
balloc(uint dev)
{
8010144b:	55                   	push   %ebp
8010144c:	89 e5                	mov    %esp,%ebp
8010144e:	83 ec 18             	sub    $0x18,%esp
  int b, bi, m;
  struct buf *bp;

  bp = 0;
80101451:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  for(b = 0; b < sb.size; b += BPB){
80101458:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010145f:	e9 0b 01 00 00       	jmp    8010156f <balloc+0x124>
    bp = bread(dev, BBLOCK(b, sb));
80101464:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101467:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
8010146d:	85 c0                	test   %eax,%eax
8010146f:	0f 48 c2             	cmovs  %edx,%eax
80101472:	c1 f8 0c             	sar    $0xc,%eax
80101475:	89 c2                	mov    %eax,%edx
80101477:	a1 d8 01 11 80       	mov    0x801101d8,%eax
8010147c:	01 d0                	add    %edx,%eax
8010147e:	83 ec 08             	sub    $0x8,%esp
80101481:	50                   	push   %eax
80101482:	ff 75 08             	push   0x8(%ebp)
80101485:	e8 2d ed ff ff       	call   801001b7 <bread>
8010148a:	83 c4 10             	add    $0x10,%esp
8010148d:	89 45 ec             	mov    %eax,-0x14(%ebp)
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
80101490:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80101497:	e9 9e 00 00 00       	jmp    8010153a <balloc+0xef>
      m = 1 << (bi % 8);
8010149c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010149f:	83 e0 07             	and    $0x7,%eax
801014a2:	ba 01 00 00 00       	mov    $0x1,%edx
801014a7:	89 c1                	mov    %eax,%ecx
801014a9:	d3 e2                	shl    %cl,%edx
801014ab:	89 d0                	mov    %edx,%eax
801014ad:	89 45 e8             	mov    %eax,-0x18(%ebp)
      if((bp->data[bi/8] & m) == 0){  // Is block free?
801014b0:	8b 45 f0             	mov    -0x10(%ebp),%eax
801014b3:	8d 50 07             	lea    0x7(%eax),%edx
801014b6:	85 c0                	test   %eax,%eax
801014b8:	0f 48 c2             	cmovs  %edx,%eax
801014bb:	c1 f8 03             	sar    $0x3,%eax
801014be:	89 c2                	mov    %eax,%edx
801014c0:	8b 45 ec             	mov    -0x14(%ebp),%eax
801014c3:	0f b6 44 10 18       	movzbl 0x18(%eax,%edx,1),%eax
801014c8:	0f b6 c0             	movzbl %al,%eax
801014cb:	23 45 e8             	and    -0x18(%ebp),%eax
801014ce:	85 c0                	test   %eax,%eax
801014d0:	75 64                	jne    80101536 <balloc+0xeb>
        bp->data[bi/8] |= m;  // Mark block in use.
801014d2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801014d5:	8d 50 07             	lea    0x7(%eax),%edx
801014d8:	85 c0                	test   %eax,%eax
801014da:	0f 48 c2             	cmovs  %edx,%eax
801014dd:	c1 f8 03             	sar    $0x3,%eax
801014e0:	8b 55 ec             	mov    -0x14(%ebp),%edx
801014e3:	0f b6 54 02 18       	movzbl 0x18(%edx,%eax,1),%edx
801014e8:	89 d1                	mov    %edx,%ecx
801014ea:	8b 55 e8             	mov    -0x18(%ebp),%edx
801014ed:	09 ca                	or     %ecx,%edx
801014ef:	89 d1                	mov    %edx,%ecx
801014f1:	8b 55 ec             	mov    -0x14(%ebp),%edx
801014f4:	88 4c 02 18          	mov    %cl,0x18(%edx,%eax,1)
        log_write(bp);
801014f8:	83 ec 0c             	sub    $0xc,%esp
801014fb:	ff 75 ec             	push   -0x14(%ebp)
801014fe:	e8 a6 22 00 00       	call   801037a9 <log_write>
80101503:	83 c4 10             	add    $0x10,%esp
        brelse(bp);
80101506:	83 ec 0c             	sub    $0xc,%esp
80101509:	ff 75 ec             	push   -0x14(%ebp)
8010150c:	e8 1e ed ff ff       	call   8010022f <brelse>
80101511:	83 c4 10             	add    $0x10,%esp
        bzero(dev, b + bi);
80101514:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101517:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010151a:	01 c2                	add    %eax,%edx
8010151c:	8b 45 08             	mov    0x8(%ebp),%eax
8010151f:	83 ec 08             	sub    $0x8,%esp
80101522:	52                   	push   %edx
80101523:	50                   	push   %eax
80101524:	e8 ce fe ff ff       	call   801013f7 <bzero>
80101529:	83 c4 10             	add    $0x10,%esp
        return b + bi;
8010152c:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010152f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101532:	01 d0                	add    %edx,%eax
80101534:	eb 56                	jmp    8010158c <balloc+0x141>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
80101536:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
8010153a:	81 7d f0 ff 0f 00 00 	cmpl   $0xfff,-0x10(%ebp)
80101541:	7f 17                	jg     8010155a <balloc+0x10f>
80101543:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101546:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101549:	01 d0                	add    %edx,%eax
8010154b:	89 c2                	mov    %eax,%edx
8010154d:	a1 c0 01 11 80       	mov    0x801101c0,%eax
80101552:	39 c2                	cmp    %eax,%edx
80101554:	0f 82 42 ff ff ff    	jb     8010149c <balloc+0x51>
      }
    }
    brelse(bp);
8010155a:	83 ec 0c             	sub    $0xc,%esp
8010155d:	ff 75 ec             	push   -0x14(%ebp)
80101560:	e8 ca ec ff ff       	call   8010022f <brelse>
80101565:	83 c4 10             	add    $0x10,%esp
  for(b = 0; b < sb.size; b += BPB){
80101568:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
8010156f:	a1 c0 01 11 80       	mov    0x801101c0,%eax
80101574:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101577:	39 c2                	cmp    %eax,%edx
80101579:	0f 82 e5 fe ff ff    	jb     80101464 <balloc+0x19>
  }
  panic("balloc: out of blocks");
8010157f:	83 ec 0c             	sub    $0xc,%esp
80101582:	68 a4 88 10 80       	push   $0x801088a4
80101587:	e8 ed ef ff ff       	call   80100579 <panic>
}
8010158c:	c9                   	leave
8010158d:	c3                   	ret

8010158e <bfree>:

// Free a disk block.
static void
bfree(int dev, uint b)
{
8010158e:	55                   	push   %ebp
8010158f:	89 e5                	mov    %esp,%ebp
80101591:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;
  int bi, m;

  readsb(dev, &sb);
80101594:	83 ec 08             	sub    $0x8,%esp
80101597:	68 c0 01 11 80       	push   $0x801101c0
8010159c:	ff 75 08             	push   0x8(%ebp)
8010159f:	e8 11 fe ff ff       	call   801013b5 <readsb>
801015a4:	83 c4 10             	add    $0x10,%esp
  bp = bread(dev, BBLOCK(b, sb));
801015a7:	8b 45 0c             	mov    0xc(%ebp),%eax
801015aa:	c1 e8 0c             	shr    $0xc,%eax
801015ad:	89 c2                	mov    %eax,%edx
801015af:	a1 d8 01 11 80       	mov    0x801101d8,%eax
801015b4:	01 c2                	add    %eax,%edx
801015b6:	8b 45 08             	mov    0x8(%ebp),%eax
801015b9:	83 ec 08             	sub    $0x8,%esp
801015bc:	52                   	push   %edx
801015bd:	50                   	push   %eax
801015be:	e8 f4 eb ff ff       	call   801001b7 <bread>
801015c3:	83 c4 10             	add    $0x10,%esp
801015c6:	89 45 f4             	mov    %eax,-0xc(%ebp)
  bi = b % BPB;
801015c9:	8b 45 0c             	mov    0xc(%ebp),%eax
801015cc:	25 ff 0f 00 00       	and    $0xfff,%eax
801015d1:	89 45 f0             	mov    %eax,-0x10(%ebp)
  m = 1 << (bi % 8);
801015d4:	8b 45 f0             	mov    -0x10(%ebp),%eax
801015d7:	83 e0 07             	and    $0x7,%eax
801015da:	ba 01 00 00 00       	mov    $0x1,%edx
801015df:	89 c1                	mov    %eax,%ecx
801015e1:	d3 e2                	shl    %cl,%edx
801015e3:	89 d0                	mov    %edx,%eax
801015e5:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((bp->data[bi/8] & m) == 0)
801015e8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801015eb:	8d 50 07             	lea    0x7(%eax),%edx
801015ee:	85 c0                	test   %eax,%eax
801015f0:	0f 48 c2             	cmovs  %edx,%eax
801015f3:	c1 f8 03             	sar    $0x3,%eax
801015f6:	89 c2                	mov    %eax,%edx
801015f8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801015fb:	0f b6 44 10 18       	movzbl 0x18(%eax,%edx,1),%eax
80101600:	0f b6 c0             	movzbl %al,%eax
80101603:	23 45 ec             	and    -0x14(%ebp),%eax
80101606:	85 c0                	test   %eax,%eax
80101608:	75 0d                	jne    80101617 <bfree+0x89>
    panic("freeing free block");
8010160a:	83 ec 0c             	sub    $0xc,%esp
8010160d:	68 ba 88 10 80       	push   $0x801088ba
80101612:	e8 62 ef ff ff       	call   80100579 <panic>
  bp->data[bi/8] &= ~m;
80101617:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010161a:	8d 50 07             	lea    0x7(%eax),%edx
8010161d:	85 c0                	test   %eax,%eax
8010161f:	0f 48 c2             	cmovs  %edx,%eax
80101622:	c1 f8 03             	sar    $0x3,%eax
80101625:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101628:	0f b6 54 02 18       	movzbl 0x18(%edx,%eax,1),%edx
8010162d:	89 d1                	mov    %edx,%ecx
8010162f:	8b 55 ec             	mov    -0x14(%ebp),%edx
80101632:	f7 d2                	not    %edx
80101634:	21 ca                	and    %ecx,%edx
80101636:	89 d1                	mov    %edx,%ecx
80101638:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010163b:	88 4c 02 18          	mov    %cl,0x18(%edx,%eax,1)
  log_write(bp);
8010163f:	83 ec 0c             	sub    $0xc,%esp
80101642:	ff 75 f4             	push   -0xc(%ebp)
80101645:	e8 5f 21 00 00       	call   801037a9 <log_write>
8010164a:	83 c4 10             	add    $0x10,%esp
  brelse(bp);
8010164d:	83 ec 0c             	sub    $0xc,%esp
80101650:	ff 75 f4             	push   -0xc(%ebp)
80101653:	e8 d7 eb ff ff       	call   8010022f <brelse>
80101658:	83 c4 10             	add    $0x10,%esp
}
8010165b:	90                   	nop
8010165c:	c9                   	leave
8010165d:	c3                   	ret

8010165e <iinit>:
  struct inode inode[NINODE];
} icache;

void
iinit(int dev)
{
8010165e:	55                   	push   %ebp
8010165f:	89 e5                	mov    %esp,%ebp
80101661:	57                   	push   %edi
80101662:	56                   	push   %esi
80101663:	53                   	push   %ebx
80101664:	83 ec 1c             	sub    $0x1c,%esp
  initlock(&icache.lock, "icache");
80101667:	83 ec 08             	sub    $0x8,%esp
8010166a:	68 cd 88 10 80       	push   $0x801088cd
8010166f:	68 e0 01 11 80       	push   $0x801101e0
80101674:	e8 e4 39 00 00       	call   8010505d <initlock>
80101679:	83 c4 10             	add    $0x10,%esp
  readsb(dev, &sb);
8010167c:	83 ec 08             	sub    $0x8,%esp
8010167f:	68 c0 01 11 80       	push   $0x801101c0
80101684:	ff 75 08             	push   0x8(%ebp)
80101687:	e8 29 fd ff ff       	call   801013b5 <readsb>
8010168c:	83 c4 10             	add    $0x10,%esp
  cprintf("sb: size %d nblocks %d ninodes %d nlog %d logstart %d inodestart %d bmap start %d\n", sb.size,
8010168f:	a1 d8 01 11 80       	mov    0x801101d8,%eax
80101694:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80101697:	8b 3d d4 01 11 80    	mov    0x801101d4,%edi
8010169d:	8b 35 d0 01 11 80    	mov    0x801101d0,%esi
801016a3:	8b 1d cc 01 11 80    	mov    0x801101cc,%ebx
801016a9:	8b 0d c8 01 11 80    	mov    0x801101c8,%ecx
801016af:	8b 15 c4 01 11 80    	mov    0x801101c4,%edx
801016b5:	a1 c0 01 11 80       	mov    0x801101c0,%eax
801016ba:	ff 75 e4             	push   -0x1c(%ebp)
801016bd:	57                   	push   %edi
801016be:	56                   	push   %esi
801016bf:	53                   	push   %ebx
801016c0:	51                   	push   %ecx
801016c1:	52                   	push   %edx
801016c2:	50                   	push   %eax
801016c3:	68 d4 88 10 80       	push   $0x801088d4
801016c8:	e8 f7 ec ff ff       	call   801003c4 <cprintf>
801016cd:	83 c4 20             	add    $0x20,%esp
          sb.nblocks, sb.ninodes, sb.nlog, sb.logstart, sb.inodestart, sb.bmapstart);
}
801016d0:	90                   	nop
801016d1:	8d 65 f4             	lea    -0xc(%ebp),%esp
801016d4:	5b                   	pop    %ebx
801016d5:	5e                   	pop    %esi
801016d6:	5f                   	pop    %edi
801016d7:	5d                   	pop    %ebp
801016d8:	c3                   	ret

801016d9 <ialloc>:
//PAGEBREAK!
// Allocate a new inode with the given type on device dev.
// A free inode has a type of zero.
struct inode*
ialloc(uint dev, short type)
{
801016d9:	55                   	push   %ebp
801016da:	89 e5                	mov    %esp,%ebp
801016dc:	83 ec 28             	sub    $0x28,%esp
801016df:	8b 45 0c             	mov    0xc(%ebp),%eax
801016e2:	66 89 45 e4          	mov    %ax,-0x1c(%ebp)
  int inum;
  struct buf *bp;
  struct dinode *dip;

  for(inum = 1; inum < sb.ninodes; inum++){
801016e6:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
801016ed:	e9 9e 00 00 00       	jmp    80101790 <ialloc+0xb7>
    bp = bread(dev, IBLOCK(inum, sb));
801016f2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801016f5:	c1 e8 03             	shr    $0x3,%eax
801016f8:	89 c2                	mov    %eax,%edx
801016fa:	a1 d4 01 11 80       	mov    0x801101d4,%eax
801016ff:	01 d0                	add    %edx,%eax
80101701:	83 ec 08             	sub    $0x8,%esp
80101704:	50                   	push   %eax
80101705:	ff 75 08             	push   0x8(%ebp)
80101708:	e8 aa ea ff ff       	call   801001b7 <bread>
8010170d:	83 c4 10             	add    $0x10,%esp
80101710:	89 45 f0             	mov    %eax,-0x10(%ebp)
    dip = (struct dinode*)bp->data + inum%IPB;
80101713:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101716:	8d 50 18             	lea    0x18(%eax),%edx
80101719:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010171c:	83 e0 07             	and    $0x7,%eax
8010171f:	c1 e0 06             	shl    $0x6,%eax
80101722:	01 d0                	add    %edx,%eax
80101724:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if(dip->type == 0){  // a free inode
80101727:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010172a:	0f b7 00             	movzwl (%eax),%eax
8010172d:	66 85 c0             	test   %ax,%ax
80101730:	75 4c                	jne    8010177e <ialloc+0xa5>
      memset(dip, 0, sizeof(*dip));
80101732:	83 ec 04             	sub    $0x4,%esp
80101735:	6a 40                	push   $0x40
80101737:	6a 00                	push   $0x0
80101739:	ff 75 ec             	push   -0x14(%ebp)
8010173c:	e8 a2 3b 00 00       	call   801052e3 <memset>
80101741:	83 c4 10             	add    $0x10,%esp
      dip->type = type;
80101744:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101747:	0f b7 55 e4          	movzwl -0x1c(%ebp),%edx
8010174b:	66 89 10             	mov    %dx,(%eax)
      log_write(bp);   // mark it allocated on the disk
8010174e:	83 ec 0c             	sub    $0xc,%esp
80101751:	ff 75 f0             	push   -0x10(%ebp)
80101754:	e8 50 20 00 00       	call   801037a9 <log_write>
80101759:	83 c4 10             	add    $0x10,%esp
      brelse(bp);
8010175c:	83 ec 0c             	sub    $0xc,%esp
8010175f:	ff 75 f0             	push   -0x10(%ebp)
80101762:	e8 c8 ea ff ff       	call   8010022f <brelse>
80101767:	83 c4 10             	add    $0x10,%esp
      return iget(dev, inum);
8010176a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010176d:	83 ec 08             	sub    $0x8,%esp
80101770:	50                   	push   %eax
80101771:	ff 75 08             	push   0x8(%ebp)
80101774:	e8 f7 00 00 00       	call   80101870 <iget>
80101779:	83 c4 10             	add    $0x10,%esp
8010177c:	eb 2f                	jmp    801017ad <ialloc+0xd4>
    }
    brelse(bp);
8010177e:	83 ec 0c             	sub    $0xc,%esp
80101781:	ff 75 f0             	push   -0x10(%ebp)
80101784:	e8 a6 ea ff ff       	call   8010022f <brelse>
80101789:	83 c4 10             	add    $0x10,%esp
  for(inum = 1; inum < sb.ninodes; inum++){
8010178c:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80101790:	a1 c8 01 11 80       	mov    0x801101c8,%eax
80101795:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101798:	39 c2                	cmp    %eax,%edx
8010179a:	0f 82 52 ff ff ff    	jb     801016f2 <ialloc+0x19>
  }
  panic("ialloc: no inodes");
801017a0:	83 ec 0c             	sub    $0xc,%esp
801017a3:	68 27 89 10 80       	push   $0x80108927
801017a8:	e8 cc ed ff ff       	call   80100579 <panic>
}
801017ad:	c9                   	leave
801017ae:	c3                   	ret

801017af <iupdate>:

// Copy a modified in-memory inode to disk.
void
iupdate(struct inode *ip)
{
801017af:	55                   	push   %ebp
801017b0:	89 e5                	mov    %esp,%ebp
801017b2:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;
  struct dinode *dip;

  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
801017b5:	8b 45 08             	mov    0x8(%ebp),%eax
801017b8:	8b 40 04             	mov    0x4(%eax),%eax
801017bb:	c1 e8 03             	shr    $0x3,%eax
801017be:	89 c2                	mov    %eax,%edx
801017c0:	a1 d4 01 11 80       	mov    0x801101d4,%eax
801017c5:	01 c2                	add    %eax,%edx
801017c7:	8b 45 08             	mov    0x8(%ebp),%eax
801017ca:	8b 00                	mov    (%eax),%eax
801017cc:	83 ec 08             	sub    $0x8,%esp
801017cf:	52                   	push   %edx
801017d0:	50                   	push   %eax
801017d1:	e8 e1 e9 ff ff       	call   801001b7 <bread>
801017d6:	83 c4 10             	add    $0x10,%esp
801017d9:	89 45 f4             	mov    %eax,-0xc(%ebp)
  dip = (struct dinode*)bp->data + ip->inum%IPB;
801017dc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801017df:	8d 50 18             	lea    0x18(%eax),%edx
801017e2:	8b 45 08             	mov    0x8(%ebp),%eax
801017e5:	8b 40 04             	mov    0x4(%eax),%eax
801017e8:	83 e0 07             	and    $0x7,%eax
801017eb:	c1 e0 06             	shl    $0x6,%eax
801017ee:	01 d0                	add    %edx,%eax
801017f0:	89 45 f0             	mov    %eax,-0x10(%ebp)
  dip->type = ip->type;
801017f3:	8b 45 08             	mov    0x8(%ebp),%eax
801017f6:	0f b7 50 10          	movzwl 0x10(%eax),%edx
801017fa:	8b 45 f0             	mov    -0x10(%ebp),%eax
801017fd:	66 89 10             	mov    %dx,(%eax)
  dip->major = ip->major;
80101800:	8b 45 08             	mov    0x8(%ebp),%eax
80101803:	0f b7 50 12          	movzwl 0x12(%eax),%edx
80101807:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010180a:	66 89 50 02          	mov    %dx,0x2(%eax)
  dip->minor = ip->minor;
8010180e:	8b 45 08             	mov    0x8(%ebp),%eax
80101811:	0f b7 50 14          	movzwl 0x14(%eax),%edx
80101815:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101818:	66 89 50 04          	mov    %dx,0x4(%eax)
  dip->nlink = ip->nlink;
8010181c:	8b 45 08             	mov    0x8(%ebp),%eax
8010181f:	0f b7 50 16          	movzwl 0x16(%eax),%edx
80101823:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101826:	66 89 50 06          	mov    %dx,0x6(%eax)
  dip->size = ip->size;
8010182a:	8b 45 08             	mov    0x8(%ebp),%eax
8010182d:	8b 50 18             	mov    0x18(%eax),%edx
80101830:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101833:	89 50 08             	mov    %edx,0x8(%eax)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
80101836:	8b 45 08             	mov    0x8(%ebp),%eax
80101839:	8d 50 1c             	lea    0x1c(%eax),%edx
8010183c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010183f:	83 c0 0c             	add    $0xc,%eax
80101842:	83 ec 04             	sub    $0x4,%esp
80101845:	6a 34                	push   $0x34
80101847:	52                   	push   %edx
80101848:	50                   	push   %eax
80101849:	e8 54 3b 00 00       	call   801053a2 <memmove>
8010184e:	83 c4 10             	add    $0x10,%esp
  log_write(bp);
80101851:	83 ec 0c             	sub    $0xc,%esp
80101854:	ff 75 f4             	push   -0xc(%ebp)
80101857:	e8 4d 1f 00 00       	call   801037a9 <log_write>
8010185c:	83 c4 10             	add    $0x10,%esp
  brelse(bp);
8010185f:	83 ec 0c             	sub    $0xc,%esp
80101862:	ff 75 f4             	push   -0xc(%ebp)
80101865:	e8 c5 e9 ff ff       	call   8010022f <brelse>
8010186a:	83 c4 10             	add    $0x10,%esp
}
8010186d:	90                   	nop
8010186e:	c9                   	leave
8010186f:	c3                   	ret

80101870 <iget>:
// Find the inode with number inum on device dev
// and return the in-memory copy. Does not lock
// the inode and does not read it from disk.
static struct inode*
iget(uint dev, uint inum)
{
80101870:	55                   	push   %ebp
80101871:	89 e5                	mov    %esp,%ebp
80101873:	83 ec 18             	sub    $0x18,%esp
  struct inode *ip, *empty;

  acquire(&icache.lock);
80101876:	83 ec 0c             	sub    $0xc,%esp
80101879:	68 e0 01 11 80       	push   $0x801101e0
8010187e:	e8 fc 37 00 00       	call   8010507f <acquire>
80101883:	83 c4 10             	add    $0x10,%esp

  // Is the inode already cached?
  empty = 0;
80101886:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
8010188d:	c7 45 f4 14 02 11 80 	movl   $0x80110214,-0xc(%ebp)
80101894:	eb 5d                	jmp    801018f3 <iget+0x83>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
80101896:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101899:	8b 40 08             	mov    0x8(%eax),%eax
8010189c:	85 c0                	test   %eax,%eax
8010189e:	7e 39                	jle    801018d9 <iget+0x69>
801018a0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801018a3:	8b 00                	mov    (%eax),%eax
801018a5:	39 45 08             	cmp    %eax,0x8(%ebp)
801018a8:	75 2f                	jne    801018d9 <iget+0x69>
801018aa:	8b 45 f4             	mov    -0xc(%ebp),%eax
801018ad:	8b 40 04             	mov    0x4(%eax),%eax
801018b0:	39 45 0c             	cmp    %eax,0xc(%ebp)
801018b3:	75 24                	jne    801018d9 <iget+0x69>
      ip->ref++;
801018b5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801018b8:	8b 40 08             	mov    0x8(%eax),%eax
801018bb:	8d 50 01             	lea    0x1(%eax),%edx
801018be:	8b 45 f4             	mov    -0xc(%ebp),%eax
801018c1:	89 50 08             	mov    %edx,0x8(%eax)
      release(&icache.lock);
801018c4:	83 ec 0c             	sub    $0xc,%esp
801018c7:	68 e0 01 11 80       	push   $0x801101e0
801018cc:	e8 15 38 00 00       	call   801050e6 <release>
801018d1:	83 c4 10             	add    $0x10,%esp
      return ip;
801018d4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801018d7:	eb 74                	jmp    8010194d <iget+0xdd>
    }
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
801018d9:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801018dd:	75 10                	jne    801018ef <iget+0x7f>
801018df:	8b 45 f4             	mov    -0xc(%ebp),%eax
801018e2:	8b 40 08             	mov    0x8(%eax),%eax
801018e5:	85 c0                	test   %eax,%eax
801018e7:	75 06                	jne    801018ef <iget+0x7f>
      empty = ip;
801018e9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801018ec:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
801018ef:	83 45 f4 50          	addl   $0x50,-0xc(%ebp)
801018f3:	81 7d f4 b4 11 11 80 	cmpl   $0x801111b4,-0xc(%ebp)
801018fa:	72 9a                	jb     80101896 <iget+0x26>
  }

  // Recycle an inode cache entry.
  if(empty == 0)
801018fc:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80101900:	75 0d                	jne    8010190f <iget+0x9f>
    panic("iget: no inodes");
80101902:	83 ec 0c             	sub    $0xc,%esp
80101905:	68 39 89 10 80       	push   $0x80108939
8010190a:	e8 6a ec ff ff       	call   80100579 <panic>

  ip = empty;
8010190f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101912:	89 45 f4             	mov    %eax,-0xc(%ebp)
  ip->dev = dev;
80101915:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101918:	8b 55 08             	mov    0x8(%ebp),%edx
8010191b:	89 10                	mov    %edx,(%eax)
  ip->inum = inum;
8010191d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101920:	8b 55 0c             	mov    0xc(%ebp),%edx
80101923:	89 50 04             	mov    %edx,0x4(%eax)
  ip->ref = 1;
80101926:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101929:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
  ip->flags = 0;
80101930:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101933:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
  release(&icache.lock);
8010193a:	83 ec 0c             	sub    $0xc,%esp
8010193d:	68 e0 01 11 80       	push   $0x801101e0
80101942:	e8 9f 37 00 00       	call   801050e6 <release>
80101947:	83 c4 10             	add    $0x10,%esp

  return ip;
8010194a:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
8010194d:	c9                   	leave
8010194e:	c3                   	ret

8010194f <idup>:

// Increment reference count for ip.
// Returns ip to enable ip = idup(ip1) idiom.
struct inode*
idup(struct inode *ip)
{
8010194f:	55                   	push   %ebp
80101950:	89 e5                	mov    %esp,%ebp
80101952:	83 ec 08             	sub    $0x8,%esp
  acquire(&icache.lock);
80101955:	83 ec 0c             	sub    $0xc,%esp
80101958:	68 e0 01 11 80       	push   $0x801101e0
8010195d:	e8 1d 37 00 00       	call   8010507f <acquire>
80101962:	83 c4 10             	add    $0x10,%esp
  ip->ref++;
80101965:	8b 45 08             	mov    0x8(%ebp),%eax
80101968:	8b 40 08             	mov    0x8(%eax),%eax
8010196b:	8d 50 01             	lea    0x1(%eax),%edx
8010196e:	8b 45 08             	mov    0x8(%ebp),%eax
80101971:	89 50 08             	mov    %edx,0x8(%eax)
  release(&icache.lock);
80101974:	83 ec 0c             	sub    $0xc,%esp
80101977:	68 e0 01 11 80       	push   $0x801101e0
8010197c:	e8 65 37 00 00       	call   801050e6 <release>
80101981:	83 c4 10             	add    $0x10,%esp
  return ip;
80101984:	8b 45 08             	mov    0x8(%ebp),%eax
}
80101987:	c9                   	leave
80101988:	c3                   	ret

80101989 <ilock>:

// Lock the given inode.
// Reads the inode from disk if necessary.
void
ilock(struct inode *ip)
{
80101989:	55                   	push   %ebp
8010198a:	89 e5                	mov    %esp,%ebp
8010198c:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;
  struct dinode *dip;

  if(ip == 0 || ip->ref < 1)
8010198f:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80101993:	74 0a                	je     8010199f <ilock+0x16>
80101995:	8b 45 08             	mov    0x8(%ebp),%eax
80101998:	8b 40 08             	mov    0x8(%eax),%eax
8010199b:	85 c0                	test   %eax,%eax
8010199d:	7f 0d                	jg     801019ac <ilock+0x23>
    panic("ilock");
8010199f:	83 ec 0c             	sub    $0xc,%esp
801019a2:	68 49 89 10 80       	push   $0x80108949
801019a7:	e8 cd eb ff ff       	call   80100579 <panic>

  acquire(&icache.lock);
801019ac:	83 ec 0c             	sub    $0xc,%esp
801019af:	68 e0 01 11 80       	push   $0x801101e0
801019b4:	e8 c6 36 00 00       	call   8010507f <acquire>
801019b9:	83 c4 10             	add    $0x10,%esp
  while(ip->flags & I_BUSY)
801019bc:	eb 13                	jmp    801019d1 <ilock+0x48>
    sleep(ip, &icache.lock);
801019be:	83 ec 08             	sub    $0x8,%esp
801019c1:	68 e0 01 11 80       	push   $0x801101e0
801019c6:	ff 75 08             	push   0x8(%ebp)
801019c9:	e8 b6 33 00 00       	call   80104d84 <sleep>
801019ce:	83 c4 10             	add    $0x10,%esp
  while(ip->flags & I_BUSY)
801019d1:	8b 45 08             	mov    0x8(%ebp),%eax
801019d4:	8b 40 0c             	mov    0xc(%eax),%eax
801019d7:	83 e0 01             	and    $0x1,%eax
801019da:	85 c0                	test   %eax,%eax
801019dc:	75 e0                	jne    801019be <ilock+0x35>
  ip->flags |= I_BUSY;
801019de:	8b 45 08             	mov    0x8(%ebp),%eax
801019e1:	8b 40 0c             	mov    0xc(%eax),%eax
801019e4:	83 c8 01             	or     $0x1,%eax
801019e7:	89 c2                	mov    %eax,%edx
801019e9:	8b 45 08             	mov    0x8(%ebp),%eax
801019ec:	89 50 0c             	mov    %edx,0xc(%eax)
  release(&icache.lock);
801019ef:	83 ec 0c             	sub    $0xc,%esp
801019f2:	68 e0 01 11 80       	push   $0x801101e0
801019f7:	e8 ea 36 00 00       	call   801050e6 <release>
801019fc:	83 c4 10             	add    $0x10,%esp

  if(!(ip->flags & I_VALID)){
801019ff:	8b 45 08             	mov    0x8(%ebp),%eax
80101a02:	8b 40 0c             	mov    0xc(%eax),%eax
80101a05:	83 e0 02             	and    $0x2,%eax
80101a08:	85 c0                	test   %eax,%eax
80101a0a:	0f 85 d4 00 00 00    	jne    80101ae4 <ilock+0x15b>
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
80101a10:	8b 45 08             	mov    0x8(%ebp),%eax
80101a13:	8b 40 04             	mov    0x4(%eax),%eax
80101a16:	c1 e8 03             	shr    $0x3,%eax
80101a19:	89 c2                	mov    %eax,%edx
80101a1b:	a1 d4 01 11 80       	mov    0x801101d4,%eax
80101a20:	01 c2                	add    %eax,%edx
80101a22:	8b 45 08             	mov    0x8(%ebp),%eax
80101a25:	8b 00                	mov    (%eax),%eax
80101a27:	83 ec 08             	sub    $0x8,%esp
80101a2a:	52                   	push   %edx
80101a2b:	50                   	push   %eax
80101a2c:	e8 86 e7 ff ff       	call   801001b7 <bread>
80101a31:	83 c4 10             	add    $0x10,%esp
80101a34:	89 45 f4             	mov    %eax,-0xc(%ebp)
    dip = (struct dinode*)bp->data + ip->inum%IPB;
80101a37:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101a3a:	8d 50 18             	lea    0x18(%eax),%edx
80101a3d:	8b 45 08             	mov    0x8(%ebp),%eax
80101a40:	8b 40 04             	mov    0x4(%eax),%eax
80101a43:	83 e0 07             	and    $0x7,%eax
80101a46:	c1 e0 06             	shl    $0x6,%eax
80101a49:	01 d0                	add    %edx,%eax
80101a4b:	89 45 f0             	mov    %eax,-0x10(%ebp)
    ip->type = dip->type;
80101a4e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101a51:	0f b7 10             	movzwl (%eax),%edx
80101a54:	8b 45 08             	mov    0x8(%ebp),%eax
80101a57:	66 89 50 10          	mov    %dx,0x10(%eax)
    ip->major = dip->major;
80101a5b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101a5e:	0f b7 50 02          	movzwl 0x2(%eax),%edx
80101a62:	8b 45 08             	mov    0x8(%ebp),%eax
80101a65:	66 89 50 12          	mov    %dx,0x12(%eax)
    ip->minor = dip->minor;
80101a69:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101a6c:	0f b7 50 04          	movzwl 0x4(%eax),%edx
80101a70:	8b 45 08             	mov    0x8(%ebp),%eax
80101a73:	66 89 50 14          	mov    %dx,0x14(%eax)
    ip->nlink = dip->nlink;
80101a77:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101a7a:	0f b7 50 06          	movzwl 0x6(%eax),%edx
80101a7e:	8b 45 08             	mov    0x8(%ebp),%eax
80101a81:	66 89 50 16          	mov    %dx,0x16(%eax)
    ip->size = dip->size;
80101a85:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101a88:	8b 50 08             	mov    0x8(%eax),%edx
80101a8b:	8b 45 08             	mov    0x8(%ebp),%eax
80101a8e:	89 50 18             	mov    %edx,0x18(%eax)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
80101a91:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101a94:	8d 50 0c             	lea    0xc(%eax),%edx
80101a97:	8b 45 08             	mov    0x8(%ebp),%eax
80101a9a:	83 c0 1c             	add    $0x1c,%eax
80101a9d:	83 ec 04             	sub    $0x4,%esp
80101aa0:	6a 34                	push   $0x34
80101aa2:	52                   	push   %edx
80101aa3:	50                   	push   %eax
80101aa4:	e8 f9 38 00 00       	call   801053a2 <memmove>
80101aa9:	83 c4 10             	add    $0x10,%esp
    brelse(bp);
80101aac:	83 ec 0c             	sub    $0xc,%esp
80101aaf:	ff 75 f4             	push   -0xc(%ebp)
80101ab2:	e8 78 e7 ff ff       	call   8010022f <brelse>
80101ab7:	83 c4 10             	add    $0x10,%esp
    ip->flags |= I_VALID;
80101aba:	8b 45 08             	mov    0x8(%ebp),%eax
80101abd:	8b 40 0c             	mov    0xc(%eax),%eax
80101ac0:	83 c8 02             	or     $0x2,%eax
80101ac3:	89 c2                	mov    %eax,%edx
80101ac5:	8b 45 08             	mov    0x8(%ebp),%eax
80101ac8:	89 50 0c             	mov    %edx,0xc(%eax)
    if(ip->type == 0)
80101acb:	8b 45 08             	mov    0x8(%ebp),%eax
80101ace:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80101ad2:	66 85 c0             	test   %ax,%ax
80101ad5:	75 0d                	jne    80101ae4 <ilock+0x15b>
      panic("ilock: no type");
80101ad7:	83 ec 0c             	sub    $0xc,%esp
80101ada:	68 4f 89 10 80       	push   $0x8010894f
80101adf:	e8 95 ea ff ff       	call   80100579 <panic>
  }
}
80101ae4:	90                   	nop
80101ae5:	c9                   	leave
80101ae6:	c3                   	ret

80101ae7 <iunlock>:

// Unlock the given inode.
void
iunlock(struct inode *ip)
{
80101ae7:	55                   	push   %ebp
80101ae8:	89 e5                	mov    %esp,%ebp
80101aea:	83 ec 08             	sub    $0x8,%esp
  if(ip == 0 || !(ip->flags & I_BUSY) || ip->ref < 1)
80101aed:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80101af1:	74 17                	je     80101b0a <iunlock+0x23>
80101af3:	8b 45 08             	mov    0x8(%ebp),%eax
80101af6:	8b 40 0c             	mov    0xc(%eax),%eax
80101af9:	83 e0 01             	and    $0x1,%eax
80101afc:	85 c0                	test   %eax,%eax
80101afe:	74 0a                	je     80101b0a <iunlock+0x23>
80101b00:	8b 45 08             	mov    0x8(%ebp),%eax
80101b03:	8b 40 08             	mov    0x8(%eax),%eax
80101b06:	85 c0                	test   %eax,%eax
80101b08:	7f 0d                	jg     80101b17 <iunlock+0x30>
    panic("iunlock");
80101b0a:	83 ec 0c             	sub    $0xc,%esp
80101b0d:	68 5e 89 10 80       	push   $0x8010895e
80101b12:	e8 62 ea ff ff       	call   80100579 <panic>

  acquire(&icache.lock);
80101b17:	83 ec 0c             	sub    $0xc,%esp
80101b1a:	68 e0 01 11 80       	push   $0x801101e0
80101b1f:	e8 5b 35 00 00       	call   8010507f <acquire>
80101b24:	83 c4 10             	add    $0x10,%esp
  ip->flags &= ~I_BUSY;
80101b27:	8b 45 08             	mov    0x8(%ebp),%eax
80101b2a:	8b 40 0c             	mov    0xc(%eax),%eax
80101b2d:	83 e0 fe             	and    $0xfffffffe,%eax
80101b30:	89 c2                	mov    %eax,%edx
80101b32:	8b 45 08             	mov    0x8(%ebp),%eax
80101b35:	89 50 0c             	mov    %edx,0xc(%eax)
  wakeup(ip);
80101b38:	83 ec 0c             	sub    $0xc,%esp
80101b3b:	ff 75 08             	push   0x8(%ebp)
80101b3e:	e8 2d 33 00 00       	call   80104e70 <wakeup>
80101b43:	83 c4 10             	add    $0x10,%esp
  release(&icache.lock);
80101b46:	83 ec 0c             	sub    $0xc,%esp
80101b49:	68 e0 01 11 80       	push   $0x801101e0
80101b4e:	e8 93 35 00 00       	call   801050e6 <release>
80101b53:	83 c4 10             	add    $0x10,%esp
}
80101b56:	90                   	nop
80101b57:	c9                   	leave
80101b58:	c3                   	ret

80101b59 <iput>:
// to it, free the inode (and its content) on disk.
// All calls to iput() must be inside a transaction in
// case it has to free the inode.
void
iput(struct inode *ip)
{
80101b59:	55                   	push   %ebp
80101b5a:	89 e5                	mov    %esp,%ebp
80101b5c:	83 ec 08             	sub    $0x8,%esp
  acquire(&icache.lock);
80101b5f:	83 ec 0c             	sub    $0xc,%esp
80101b62:	68 e0 01 11 80       	push   $0x801101e0
80101b67:	e8 13 35 00 00       	call   8010507f <acquire>
80101b6c:	83 c4 10             	add    $0x10,%esp
  if(ip->ref == 1 && (ip->flags & I_VALID) && ip->nlink == 0){
80101b6f:	8b 45 08             	mov    0x8(%ebp),%eax
80101b72:	8b 40 08             	mov    0x8(%eax),%eax
80101b75:	83 f8 01             	cmp    $0x1,%eax
80101b78:	0f 85 a9 00 00 00    	jne    80101c27 <iput+0xce>
80101b7e:	8b 45 08             	mov    0x8(%ebp),%eax
80101b81:	8b 40 0c             	mov    0xc(%eax),%eax
80101b84:	83 e0 02             	and    $0x2,%eax
80101b87:	85 c0                	test   %eax,%eax
80101b89:	0f 84 98 00 00 00    	je     80101c27 <iput+0xce>
80101b8f:	8b 45 08             	mov    0x8(%ebp),%eax
80101b92:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80101b96:	66 85 c0             	test   %ax,%ax
80101b99:	0f 85 88 00 00 00    	jne    80101c27 <iput+0xce>
    // inode has no links and no other references: truncate and free.
    if(ip->flags & I_BUSY)
80101b9f:	8b 45 08             	mov    0x8(%ebp),%eax
80101ba2:	8b 40 0c             	mov    0xc(%eax),%eax
80101ba5:	83 e0 01             	and    $0x1,%eax
80101ba8:	85 c0                	test   %eax,%eax
80101baa:	74 0d                	je     80101bb9 <iput+0x60>
      panic("iput busy");
80101bac:	83 ec 0c             	sub    $0xc,%esp
80101baf:	68 66 89 10 80       	push   $0x80108966
80101bb4:	e8 c0 e9 ff ff       	call   80100579 <panic>
    ip->flags |= I_BUSY;
80101bb9:	8b 45 08             	mov    0x8(%ebp),%eax
80101bbc:	8b 40 0c             	mov    0xc(%eax),%eax
80101bbf:	83 c8 01             	or     $0x1,%eax
80101bc2:	89 c2                	mov    %eax,%edx
80101bc4:	8b 45 08             	mov    0x8(%ebp),%eax
80101bc7:	89 50 0c             	mov    %edx,0xc(%eax)
    release(&icache.lock);
80101bca:	83 ec 0c             	sub    $0xc,%esp
80101bcd:	68 e0 01 11 80       	push   $0x801101e0
80101bd2:	e8 0f 35 00 00       	call   801050e6 <release>
80101bd7:	83 c4 10             	add    $0x10,%esp
    itrunc(ip);
80101bda:	83 ec 0c             	sub    $0xc,%esp
80101bdd:	ff 75 08             	push   0x8(%ebp)
80101be0:	e8 a3 01 00 00       	call   80101d88 <itrunc>
80101be5:	83 c4 10             	add    $0x10,%esp
    ip->type = 0;
80101be8:	8b 45 08             	mov    0x8(%ebp),%eax
80101beb:	66 c7 40 10 00 00    	movw   $0x0,0x10(%eax)
    iupdate(ip);
80101bf1:	83 ec 0c             	sub    $0xc,%esp
80101bf4:	ff 75 08             	push   0x8(%ebp)
80101bf7:	e8 b3 fb ff ff       	call   801017af <iupdate>
80101bfc:	83 c4 10             	add    $0x10,%esp
    acquire(&icache.lock);
80101bff:	83 ec 0c             	sub    $0xc,%esp
80101c02:	68 e0 01 11 80       	push   $0x801101e0
80101c07:	e8 73 34 00 00       	call   8010507f <acquire>
80101c0c:	83 c4 10             	add    $0x10,%esp
    ip->flags = 0;
80101c0f:	8b 45 08             	mov    0x8(%ebp),%eax
80101c12:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    wakeup(ip);
80101c19:	83 ec 0c             	sub    $0xc,%esp
80101c1c:	ff 75 08             	push   0x8(%ebp)
80101c1f:	e8 4c 32 00 00       	call   80104e70 <wakeup>
80101c24:	83 c4 10             	add    $0x10,%esp
  }
  ip->ref--;
80101c27:	8b 45 08             	mov    0x8(%ebp),%eax
80101c2a:	8b 40 08             	mov    0x8(%eax),%eax
80101c2d:	8d 50 ff             	lea    -0x1(%eax),%edx
80101c30:	8b 45 08             	mov    0x8(%ebp),%eax
80101c33:	89 50 08             	mov    %edx,0x8(%eax)
  release(&icache.lock);
80101c36:	83 ec 0c             	sub    $0xc,%esp
80101c39:	68 e0 01 11 80       	push   $0x801101e0
80101c3e:	e8 a3 34 00 00       	call   801050e6 <release>
80101c43:	83 c4 10             	add    $0x10,%esp
}
80101c46:	90                   	nop
80101c47:	c9                   	leave
80101c48:	c3                   	ret

80101c49 <iunlockput>:

// Common idiom: unlock, then put.
void
iunlockput(struct inode *ip)
{
80101c49:	55                   	push   %ebp
80101c4a:	89 e5                	mov    %esp,%ebp
80101c4c:	83 ec 08             	sub    $0x8,%esp
  iunlock(ip);
80101c4f:	83 ec 0c             	sub    $0xc,%esp
80101c52:	ff 75 08             	push   0x8(%ebp)
80101c55:	e8 8d fe ff ff       	call   80101ae7 <iunlock>
80101c5a:	83 c4 10             	add    $0x10,%esp
  iput(ip);
80101c5d:	83 ec 0c             	sub    $0xc,%esp
80101c60:	ff 75 08             	push   0x8(%ebp)
80101c63:	e8 f1 fe ff ff       	call   80101b59 <iput>
80101c68:	83 c4 10             	add    $0x10,%esp
}
80101c6b:	90                   	nop
80101c6c:	c9                   	leave
80101c6d:	c3                   	ret

80101c6e <bmap>:

// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
static uint
bmap(struct inode *ip, uint bn)
{
80101c6e:	55                   	push   %ebp
80101c6f:	89 e5                	mov    %esp,%ebp
80101c71:	83 ec 18             	sub    $0x18,%esp
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
80101c74:	83 7d 0c 0b          	cmpl   $0xb,0xc(%ebp)
80101c78:	77 42                	ja     80101cbc <bmap+0x4e>
    if((addr = ip->addrs[bn]) == 0)
80101c7a:	8b 45 08             	mov    0x8(%ebp),%eax
80101c7d:	8b 55 0c             	mov    0xc(%ebp),%edx
80101c80:	83 c2 04             	add    $0x4,%edx
80101c83:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80101c87:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101c8a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101c8e:	75 24                	jne    80101cb4 <bmap+0x46>
      ip->addrs[bn] = addr = balloc(ip->dev);
80101c90:	8b 45 08             	mov    0x8(%ebp),%eax
80101c93:	8b 00                	mov    (%eax),%eax
80101c95:	83 ec 0c             	sub    $0xc,%esp
80101c98:	50                   	push   %eax
80101c99:	e8 ad f7 ff ff       	call   8010144b <balloc>
80101c9e:	83 c4 10             	add    $0x10,%esp
80101ca1:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101ca4:	8b 45 08             	mov    0x8(%ebp),%eax
80101ca7:	8b 55 0c             	mov    0xc(%ebp),%edx
80101caa:	8d 4a 04             	lea    0x4(%edx),%ecx
80101cad:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101cb0:	89 54 88 0c          	mov    %edx,0xc(%eax,%ecx,4)
    return addr;
80101cb4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101cb7:	e9 ca 00 00 00       	jmp    80101d86 <bmap+0x118>
  }
  bn -= NDIRECT;
80101cbc:	83 6d 0c 0c          	subl   $0xc,0xc(%ebp)

  if(bn < NINDIRECT){
80101cc0:	83 7d 0c 7f          	cmpl   $0x7f,0xc(%ebp)
80101cc4:	0f 87 af 00 00 00    	ja     80101d79 <bmap+0x10b>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0)
80101cca:	8b 45 08             	mov    0x8(%ebp),%eax
80101ccd:	8b 40 4c             	mov    0x4c(%eax),%eax
80101cd0:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101cd3:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101cd7:	75 1d                	jne    80101cf6 <bmap+0x88>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
80101cd9:	8b 45 08             	mov    0x8(%ebp),%eax
80101cdc:	8b 00                	mov    (%eax),%eax
80101cde:	83 ec 0c             	sub    $0xc,%esp
80101ce1:	50                   	push   %eax
80101ce2:	e8 64 f7 ff ff       	call   8010144b <balloc>
80101ce7:	83 c4 10             	add    $0x10,%esp
80101cea:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101ced:	8b 45 08             	mov    0x8(%ebp),%eax
80101cf0:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101cf3:	89 50 4c             	mov    %edx,0x4c(%eax)
    bp = bread(ip->dev, addr);
80101cf6:	8b 45 08             	mov    0x8(%ebp),%eax
80101cf9:	8b 00                	mov    (%eax),%eax
80101cfb:	83 ec 08             	sub    $0x8,%esp
80101cfe:	ff 75 f4             	push   -0xc(%ebp)
80101d01:	50                   	push   %eax
80101d02:	e8 b0 e4 ff ff       	call   801001b7 <bread>
80101d07:	83 c4 10             	add    $0x10,%esp
80101d0a:	89 45 f0             	mov    %eax,-0x10(%ebp)
    a = (uint*)bp->data;
80101d0d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101d10:	83 c0 18             	add    $0x18,%eax
80101d13:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if((addr = a[bn]) == 0){
80101d16:	8b 45 0c             	mov    0xc(%ebp),%eax
80101d19:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101d20:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101d23:	01 d0                	add    %edx,%eax
80101d25:	8b 00                	mov    (%eax),%eax
80101d27:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101d2a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101d2e:	75 36                	jne    80101d66 <bmap+0xf8>
      a[bn] = addr = balloc(ip->dev);
80101d30:	8b 45 08             	mov    0x8(%ebp),%eax
80101d33:	8b 00                	mov    (%eax),%eax
80101d35:	83 ec 0c             	sub    $0xc,%esp
80101d38:	50                   	push   %eax
80101d39:	e8 0d f7 ff ff       	call   8010144b <balloc>
80101d3e:	83 c4 10             	add    $0x10,%esp
80101d41:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101d44:	8b 45 0c             	mov    0xc(%ebp),%eax
80101d47:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101d4e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101d51:	01 c2                	add    %eax,%edx
80101d53:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101d56:	89 02                	mov    %eax,(%edx)
      log_write(bp);
80101d58:	83 ec 0c             	sub    $0xc,%esp
80101d5b:	ff 75 f0             	push   -0x10(%ebp)
80101d5e:	e8 46 1a 00 00       	call   801037a9 <log_write>
80101d63:	83 c4 10             	add    $0x10,%esp
    }
    brelse(bp);
80101d66:	83 ec 0c             	sub    $0xc,%esp
80101d69:	ff 75 f0             	push   -0x10(%ebp)
80101d6c:	e8 be e4 ff ff       	call   8010022f <brelse>
80101d71:	83 c4 10             	add    $0x10,%esp
    return addr;
80101d74:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101d77:	eb 0d                	jmp    80101d86 <bmap+0x118>
  }

  panic("bmap: out of range");
80101d79:	83 ec 0c             	sub    $0xc,%esp
80101d7c:	68 70 89 10 80       	push   $0x80108970
80101d81:	e8 f3 e7 ff ff       	call   80100579 <panic>
}
80101d86:	c9                   	leave
80101d87:	c3                   	ret

80101d88 <itrunc>:
// to it (no directory entries referring to it)
// and has no in-memory reference to it (is
// not an open file or current directory).
static void
itrunc(struct inode *ip)
{
80101d88:	55                   	push   %ebp
80101d89:	89 e5                	mov    %esp,%ebp
80101d8b:	83 ec 18             	sub    $0x18,%esp
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
80101d8e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80101d95:	eb 45                	jmp    80101ddc <itrunc+0x54>
    if(ip->addrs[i]){
80101d97:	8b 45 08             	mov    0x8(%ebp),%eax
80101d9a:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101d9d:	83 c2 04             	add    $0x4,%edx
80101da0:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80101da4:	85 c0                	test   %eax,%eax
80101da6:	74 30                	je     80101dd8 <itrunc+0x50>
      bfree(ip->dev, ip->addrs[i]);
80101da8:	8b 45 08             	mov    0x8(%ebp),%eax
80101dab:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101dae:	83 c2 04             	add    $0x4,%edx
80101db1:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80101db5:	8b 55 08             	mov    0x8(%ebp),%edx
80101db8:	8b 12                	mov    (%edx),%edx
80101dba:	83 ec 08             	sub    $0x8,%esp
80101dbd:	50                   	push   %eax
80101dbe:	52                   	push   %edx
80101dbf:	e8 ca f7 ff ff       	call   8010158e <bfree>
80101dc4:	83 c4 10             	add    $0x10,%esp
      ip->addrs[i] = 0;
80101dc7:	8b 45 08             	mov    0x8(%ebp),%eax
80101dca:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101dcd:	83 c2 04             	add    $0x4,%edx
80101dd0:	c7 44 90 0c 00 00 00 	movl   $0x0,0xc(%eax,%edx,4)
80101dd7:	00 
  for(i = 0; i < NDIRECT; i++){
80101dd8:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80101ddc:	83 7d f4 0b          	cmpl   $0xb,-0xc(%ebp)
80101de0:	7e b5                	jle    80101d97 <itrunc+0xf>
    }
  }
  
  if(ip->addrs[NDIRECT]){
80101de2:	8b 45 08             	mov    0x8(%ebp),%eax
80101de5:	8b 40 4c             	mov    0x4c(%eax),%eax
80101de8:	85 c0                	test   %eax,%eax
80101dea:	0f 84 a1 00 00 00    	je     80101e91 <itrunc+0x109>
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
80101df0:	8b 45 08             	mov    0x8(%ebp),%eax
80101df3:	8b 50 4c             	mov    0x4c(%eax),%edx
80101df6:	8b 45 08             	mov    0x8(%ebp),%eax
80101df9:	8b 00                	mov    (%eax),%eax
80101dfb:	83 ec 08             	sub    $0x8,%esp
80101dfe:	52                   	push   %edx
80101dff:	50                   	push   %eax
80101e00:	e8 b2 e3 ff ff       	call   801001b7 <bread>
80101e05:	83 c4 10             	add    $0x10,%esp
80101e08:	89 45 ec             	mov    %eax,-0x14(%ebp)
    a = (uint*)bp->data;
80101e0b:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101e0e:	83 c0 18             	add    $0x18,%eax
80101e11:	89 45 e8             	mov    %eax,-0x18(%ebp)
    for(j = 0; j < NINDIRECT; j++){
80101e14:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80101e1b:	eb 3c                	jmp    80101e59 <itrunc+0xd1>
      if(a[j])
80101e1d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101e20:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101e27:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101e2a:	01 d0                	add    %edx,%eax
80101e2c:	8b 00                	mov    (%eax),%eax
80101e2e:	85 c0                	test   %eax,%eax
80101e30:	74 23                	je     80101e55 <itrunc+0xcd>
        bfree(ip->dev, a[j]);
80101e32:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101e35:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101e3c:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101e3f:	01 d0                	add    %edx,%eax
80101e41:	8b 00                	mov    (%eax),%eax
80101e43:	8b 55 08             	mov    0x8(%ebp),%edx
80101e46:	8b 12                	mov    (%edx),%edx
80101e48:	83 ec 08             	sub    $0x8,%esp
80101e4b:	50                   	push   %eax
80101e4c:	52                   	push   %edx
80101e4d:	e8 3c f7 ff ff       	call   8010158e <bfree>
80101e52:	83 c4 10             	add    $0x10,%esp
    for(j = 0; j < NINDIRECT; j++){
80101e55:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80101e59:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101e5c:	83 f8 7f             	cmp    $0x7f,%eax
80101e5f:	76 bc                	jbe    80101e1d <itrunc+0x95>
    }
    brelse(bp);
80101e61:	83 ec 0c             	sub    $0xc,%esp
80101e64:	ff 75 ec             	push   -0x14(%ebp)
80101e67:	e8 c3 e3 ff ff       	call   8010022f <brelse>
80101e6c:	83 c4 10             	add    $0x10,%esp
    bfree(ip->dev, ip->addrs[NDIRECT]);
80101e6f:	8b 45 08             	mov    0x8(%ebp),%eax
80101e72:	8b 40 4c             	mov    0x4c(%eax),%eax
80101e75:	8b 55 08             	mov    0x8(%ebp),%edx
80101e78:	8b 12                	mov    (%edx),%edx
80101e7a:	83 ec 08             	sub    $0x8,%esp
80101e7d:	50                   	push   %eax
80101e7e:	52                   	push   %edx
80101e7f:	e8 0a f7 ff ff       	call   8010158e <bfree>
80101e84:	83 c4 10             	add    $0x10,%esp
    ip->addrs[NDIRECT] = 0;
80101e87:	8b 45 08             	mov    0x8(%ebp),%eax
80101e8a:	c7 40 4c 00 00 00 00 	movl   $0x0,0x4c(%eax)
  }

  ip->size = 0;
80101e91:	8b 45 08             	mov    0x8(%ebp),%eax
80101e94:	c7 40 18 00 00 00 00 	movl   $0x0,0x18(%eax)
  iupdate(ip);
80101e9b:	83 ec 0c             	sub    $0xc,%esp
80101e9e:	ff 75 08             	push   0x8(%ebp)
80101ea1:	e8 09 f9 ff ff       	call   801017af <iupdate>
80101ea6:	83 c4 10             	add    $0x10,%esp
}
80101ea9:	90                   	nop
80101eaa:	c9                   	leave
80101eab:	c3                   	ret

80101eac <stati>:

// Copy stat information from inode.
void
stati(struct inode *ip, struct stat *st)
{
80101eac:	55                   	push   %ebp
80101ead:	89 e5                	mov    %esp,%ebp
  st->dev = ip->dev;
80101eaf:	8b 45 08             	mov    0x8(%ebp),%eax
80101eb2:	8b 00                	mov    (%eax),%eax
80101eb4:	89 c2                	mov    %eax,%edx
80101eb6:	8b 45 0c             	mov    0xc(%ebp),%eax
80101eb9:	89 50 04             	mov    %edx,0x4(%eax)
  st->ino = ip->inum;
80101ebc:	8b 45 08             	mov    0x8(%ebp),%eax
80101ebf:	8b 50 04             	mov    0x4(%eax),%edx
80101ec2:	8b 45 0c             	mov    0xc(%ebp),%eax
80101ec5:	89 50 08             	mov    %edx,0x8(%eax)
  st->type = ip->type;
80101ec8:	8b 45 08             	mov    0x8(%ebp),%eax
80101ecb:	0f b7 50 10          	movzwl 0x10(%eax),%edx
80101ecf:	8b 45 0c             	mov    0xc(%ebp),%eax
80101ed2:	66 89 10             	mov    %dx,(%eax)
  st->nlink = ip->nlink;
80101ed5:	8b 45 08             	mov    0x8(%ebp),%eax
80101ed8:	0f b7 50 16          	movzwl 0x16(%eax),%edx
80101edc:	8b 45 0c             	mov    0xc(%ebp),%eax
80101edf:	66 89 50 0c          	mov    %dx,0xc(%eax)
  st->size = ip->size;
80101ee3:	8b 45 08             	mov    0x8(%ebp),%eax
80101ee6:	8b 50 18             	mov    0x18(%eax),%edx
80101ee9:	8b 45 0c             	mov    0xc(%ebp),%eax
80101eec:	89 50 10             	mov    %edx,0x10(%eax)
}
80101eef:	90                   	nop
80101ef0:	5d                   	pop    %ebp
80101ef1:	c3                   	ret

80101ef2 <readi>:

//PAGEBREAK!
// Read data from inode.
int
readi(struct inode *ip, char *dst, uint off, uint n)
{
80101ef2:	55                   	push   %ebp
80101ef3:	89 e5                	mov    %esp,%ebp
80101ef5:	83 ec 18             	sub    $0x18,%esp
  uint tot, m;
  struct buf *bp;

  if(ip->type == T_DEV){
80101ef8:	8b 45 08             	mov    0x8(%ebp),%eax
80101efb:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80101eff:	66 83 f8 03          	cmp    $0x3,%ax
80101f03:	75 5c                	jne    80101f61 <readi+0x6f>
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].read)
80101f05:	8b 45 08             	mov    0x8(%ebp),%eax
80101f08:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80101f0c:	66 85 c0             	test   %ax,%ax
80101f0f:	78 20                	js     80101f31 <readi+0x3f>
80101f11:	8b 45 08             	mov    0x8(%ebp),%eax
80101f14:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80101f18:	66 83 f8 09          	cmp    $0x9,%ax
80101f1c:	7f 13                	jg     80101f31 <readi+0x3f>
80101f1e:	8b 45 08             	mov    0x8(%ebp),%eax
80101f21:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80101f25:	98                   	cwtl
80101f26:	8b 04 c5 c0 f7 10 80 	mov    -0x7fef0840(,%eax,8),%eax
80101f2d:	85 c0                	test   %eax,%eax
80101f2f:	75 0a                	jne    80101f3b <readi+0x49>
      return -1;
80101f31:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101f36:	e9 0a 01 00 00       	jmp    80102045 <readi+0x153>
    return devsw[ip->major].read(ip, dst, n);
80101f3b:	8b 45 08             	mov    0x8(%ebp),%eax
80101f3e:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80101f42:	98                   	cwtl
80101f43:	8b 04 c5 c0 f7 10 80 	mov    -0x7fef0840(,%eax,8),%eax
80101f4a:	8b 55 14             	mov    0x14(%ebp),%edx
80101f4d:	83 ec 04             	sub    $0x4,%esp
80101f50:	52                   	push   %edx
80101f51:	ff 75 0c             	push   0xc(%ebp)
80101f54:	ff 75 08             	push   0x8(%ebp)
80101f57:	ff d0                	call   *%eax
80101f59:	83 c4 10             	add    $0x10,%esp
80101f5c:	e9 e4 00 00 00       	jmp    80102045 <readi+0x153>
  }

  if(off > ip->size || off + n < off)
80101f61:	8b 45 08             	mov    0x8(%ebp),%eax
80101f64:	8b 40 18             	mov    0x18(%eax),%eax
80101f67:	3b 45 10             	cmp    0x10(%ebp),%eax
80101f6a:	72 0d                	jb     80101f79 <readi+0x87>
80101f6c:	8b 55 10             	mov    0x10(%ebp),%edx
80101f6f:	8b 45 14             	mov    0x14(%ebp),%eax
80101f72:	01 d0                	add    %edx,%eax
80101f74:	3b 45 10             	cmp    0x10(%ebp),%eax
80101f77:	73 0a                	jae    80101f83 <readi+0x91>
    return -1;
80101f79:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101f7e:	e9 c2 00 00 00       	jmp    80102045 <readi+0x153>
  if(off + n > ip->size)
80101f83:	8b 55 10             	mov    0x10(%ebp),%edx
80101f86:	8b 45 14             	mov    0x14(%ebp),%eax
80101f89:	01 c2                	add    %eax,%edx
80101f8b:	8b 45 08             	mov    0x8(%ebp),%eax
80101f8e:	8b 40 18             	mov    0x18(%eax),%eax
80101f91:	39 d0                	cmp    %edx,%eax
80101f93:	73 0c                	jae    80101fa1 <readi+0xaf>
    n = ip->size - off;
80101f95:	8b 45 08             	mov    0x8(%ebp),%eax
80101f98:	8b 40 18             	mov    0x18(%eax),%eax
80101f9b:	2b 45 10             	sub    0x10(%ebp),%eax
80101f9e:	89 45 14             	mov    %eax,0x14(%ebp)

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
80101fa1:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80101fa8:	e9 89 00 00 00       	jmp    80102036 <readi+0x144>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
80101fad:	8b 45 10             	mov    0x10(%ebp),%eax
80101fb0:	c1 e8 09             	shr    $0x9,%eax
80101fb3:	83 ec 08             	sub    $0x8,%esp
80101fb6:	50                   	push   %eax
80101fb7:	ff 75 08             	push   0x8(%ebp)
80101fba:	e8 af fc ff ff       	call   80101c6e <bmap>
80101fbf:	83 c4 10             	add    $0x10,%esp
80101fc2:	8b 55 08             	mov    0x8(%ebp),%edx
80101fc5:	8b 12                	mov    (%edx),%edx
80101fc7:	83 ec 08             	sub    $0x8,%esp
80101fca:	50                   	push   %eax
80101fcb:	52                   	push   %edx
80101fcc:	e8 e6 e1 ff ff       	call   801001b7 <bread>
80101fd1:	83 c4 10             	add    $0x10,%esp
80101fd4:	89 45 f0             	mov    %eax,-0x10(%ebp)
    m = min(n - tot, BSIZE - off%BSIZE);
80101fd7:	8b 45 10             	mov    0x10(%ebp),%eax
80101fda:	25 ff 01 00 00       	and    $0x1ff,%eax
80101fdf:	ba 00 02 00 00       	mov    $0x200,%edx
80101fe4:	29 c2                	sub    %eax,%edx
80101fe6:	8b 45 14             	mov    0x14(%ebp),%eax
80101fe9:	2b 45 f4             	sub    -0xc(%ebp),%eax
80101fec:	39 c2                	cmp    %eax,%edx
80101fee:	0f 46 c2             	cmovbe %edx,%eax
80101ff1:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(dst, bp->data + off%BSIZE, m);
80101ff4:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101ff7:	8d 50 18             	lea    0x18(%eax),%edx
80101ffa:	8b 45 10             	mov    0x10(%ebp),%eax
80101ffd:	25 ff 01 00 00       	and    $0x1ff,%eax
80102002:	01 d0                	add    %edx,%eax
80102004:	83 ec 04             	sub    $0x4,%esp
80102007:	ff 75 ec             	push   -0x14(%ebp)
8010200a:	50                   	push   %eax
8010200b:	ff 75 0c             	push   0xc(%ebp)
8010200e:	e8 8f 33 00 00       	call   801053a2 <memmove>
80102013:	83 c4 10             	add    $0x10,%esp
    brelse(bp);
80102016:	83 ec 0c             	sub    $0xc,%esp
80102019:	ff 75 f0             	push   -0x10(%ebp)
8010201c:	e8 0e e2 ff ff       	call   8010022f <brelse>
80102021:	83 c4 10             	add    $0x10,%esp
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
80102024:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102027:	01 45 f4             	add    %eax,-0xc(%ebp)
8010202a:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010202d:	01 45 10             	add    %eax,0x10(%ebp)
80102030:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102033:	01 45 0c             	add    %eax,0xc(%ebp)
80102036:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102039:	3b 45 14             	cmp    0x14(%ebp),%eax
8010203c:	0f 82 6b ff ff ff    	jb     80101fad <readi+0xbb>
  }
  return n;
80102042:	8b 45 14             	mov    0x14(%ebp),%eax
}
80102045:	c9                   	leave
80102046:	c3                   	ret

80102047 <writei>:

// PAGEBREAK!
// Write data to inode.
int
writei(struct inode *ip, char *src, uint off, uint n)
{
80102047:	55                   	push   %ebp
80102048:	89 e5                	mov    %esp,%ebp
8010204a:	83 ec 18             	sub    $0x18,%esp
  uint tot, m;
  struct buf *bp;

  if(ip->type == T_DEV){
8010204d:	8b 45 08             	mov    0x8(%ebp),%eax
80102050:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80102054:	66 83 f8 03          	cmp    $0x3,%ax
80102058:	75 5c                	jne    801020b6 <writei+0x6f>
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].write)
8010205a:	8b 45 08             	mov    0x8(%ebp),%eax
8010205d:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80102061:	66 85 c0             	test   %ax,%ax
80102064:	78 20                	js     80102086 <writei+0x3f>
80102066:	8b 45 08             	mov    0x8(%ebp),%eax
80102069:	0f b7 40 12          	movzwl 0x12(%eax),%eax
8010206d:	66 83 f8 09          	cmp    $0x9,%ax
80102071:	7f 13                	jg     80102086 <writei+0x3f>
80102073:	8b 45 08             	mov    0x8(%ebp),%eax
80102076:	0f b7 40 12          	movzwl 0x12(%eax),%eax
8010207a:	98                   	cwtl
8010207b:	8b 04 c5 c4 f7 10 80 	mov    -0x7fef083c(,%eax,8),%eax
80102082:	85 c0                	test   %eax,%eax
80102084:	75 0a                	jne    80102090 <writei+0x49>
      return -1;
80102086:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010208b:	e9 3b 01 00 00       	jmp    801021cb <writei+0x184>
    return devsw[ip->major].write(ip, src, n);
80102090:	8b 45 08             	mov    0x8(%ebp),%eax
80102093:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80102097:	98                   	cwtl
80102098:	8b 04 c5 c4 f7 10 80 	mov    -0x7fef083c(,%eax,8),%eax
8010209f:	8b 55 14             	mov    0x14(%ebp),%edx
801020a2:	83 ec 04             	sub    $0x4,%esp
801020a5:	52                   	push   %edx
801020a6:	ff 75 0c             	push   0xc(%ebp)
801020a9:	ff 75 08             	push   0x8(%ebp)
801020ac:	ff d0                	call   *%eax
801020ae:	83 c4 10             	add    $0x10,%esp
801020b1:	e9 15 01 00 00       	jmp    801021cb <writei+0x184>
  }

  if(off > ip->size || off + n < off)
801020b6:	8b 45 08             	mov    0x8(%ebp),%eax
801020b9:	8b 40 18             	mov    0x18(%eax),%eax
801020bc:	3b 45 10             	cmp    0x10(%ebp),%eax
801020bf:	72 0d                	jb     801020ce <writei+0x87>
801020c1:	8b 55 10             	mov    0x10(%ebp),%edx
801020c4:	8b 45 14             	mov    0x14(%ebp),%eax
801020c7:	01 d0                	add    %edx,%eax
801020c9:	3b 45 10             	cmp    0x10(%ebp),%eax
801020cc:	73 0a                	jae    801020d8 <writei+0x91>
    return -1;
801020ce:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801020d3:	e9 f3 00 00 00       	jmp    801021cb <writei+0x184>
  if(off + n > MAXFILE*BSIZE)
801020d8:	8b 55 10             	mov    0x10(%ebp),%edx
801020db:	8b 45 14             	mov    0x14(%ebp),%eax
801020de:	01 d0                	add    %edx,%eax
801020e0:	3d 00 18 01 00       	cmp    $0x11800,%eax
801020e5:	76 0a                	jbe    801020f1 <writei+0xaa>
    return -1;
801020e7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801020ec:	e9 da 00 00 00       	jmp    801021cb <writei+0x184>

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
801020f1:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801020f8:	e9 97 00 00 00       	jmp    80102194 <writei+0x14d>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
801020fd:	8b 45 10             	mov    0x10(%ebp),%eax
80102100:	c1 e8 09             	shr    $0x9,%eax
80102103:	83 ec 08             	sub    $0x8,%esp
80102106:	50                   	push   %eax
80102107:	ff 75 08             	push   0x8(%ebp)
8010210a:	e8 5f fb ff ff       	call   80101c6e <bmap>
8010210f:	83 c4 10             	add    $0x10,%esp
80102112:	8b 55 08             	mov    0x8(%ebp),%edx
80102115:	8b 12                	mov    (%edx),%edx
80102117:	83 ec 08             	sub    $0x8,%esp
8010211a:	50                   	push   %eax
8010211b:	52                   	push   %edx
8010211c:	e8 96 e0 ff ff       	call   801001b7 <bread>
80102121:	83 c4 10             	add    $0x10,%esp
80102124:	89 45 f0             	mov    %eax,-0x10(%ebp)
    m = min(n - tot, BSIZE - off%BSIZE);
80102127:	8b 45 10             	mov    0x10(%ebp),%eax
8010212a:	25 ff 01 00 00       	and    $0x1ff,%eax
8010212f:	ba 00 02 00 00       	mov    $0x200,%edx
80102134:	29 c2                	sub    %eax,%edx
80102136:	8b 45 14             	mov    0x14(%ebp),%eax
80102139:	2b 45 f4             	sub    -0xc(%ebp),%eax
8010213c:	39 c2                	cmp    %eax,%edx
8010213e:	0f 46 c2             	cmovbe %edx,%eax
80102141:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(bp->data + off%BSIZE, src, m);
80102144:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102147:	8d 50 18             	lea    0x18(%eax),%edx
8010214a:	8b 45 10             	mov    0x10(%ebp),%eax
8010214d:	25 ff 01 00 00       	and    $0x1ff,%eax
80102152:	01 d0                	add    %edx,%eax
80102154:	83 ec 04             	sub    $0x4,%esp
80102157:	ff 75 ec             	push   -0x14(%ebp)
8010215a:	ff 75 0c             	push   0xc(%ebp)
8010215d:	50                   	push   %eax
8010215e:	e8 3f 32 00 00       	call   801053a2 <memmove>
80102163:	83 c4 10             	add    $0x10,%esp
    log_write(bp);
80102166:	83 ec 0c             	sub    $0xc,%esp
80102169:	ff 75 f0             	push   -0x10(%ebp)
8010216c:	e8 38 16 00 00       	call   801037a9 <log_write>
80102171:	83 c4 10             	add    $0x10,%esp
    brelse(bp);
80102174:	83 ec 0c             	sub    $0xc,%esp
80102177:	ff 75 f0             	push   -0x10(%ebp)
8010217a:	e8 b0 e0 ff ff       	call   8010022f <brelse>
8010217f:	83 c4 10             	add    $0x10,%esp
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
80102182:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102185:	01 45 f4             	add    %eax,-0xc(%ebp)
80102188:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010218b:	01 45 10             	add    %eax,0x10(%ebp)
8010218e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102191:	01 45 0c             	add    %eax,0xc(%ebp)
80102194:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102197:	3b 45 14             	cmp    0x14(%ebp),%eax
8010219a:	0f 82 5d ff ff ff    	jb     801020fd <writei+0xb6>
  }

  if(n > 0 && off > ip->size){
801021a0:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
801021a4:	74 22                	je     801021c8 <writei+0x181>
801021a6:	8b 45 08             	mov    0x8(%ebp),%eax
801021a9:	8b 40 18             	mov    0x18(%eax),%eax
801021ac:	3b 45 10             	cmp    0x10(%ebp),%eax
801021af:	73 17                	jae    801021c8 <writei+0x181>
    ip->size = off;
801021b1:	8b 45 08             	mov    0x8(%ebp),%eax
801021b4:	8b 55 10             	mov    0x10(%ebp),%edx
801021b7:	89 50 18             	mov    %edx,0x18(%eax)
    iupdate(ip);
801021ba:	83 ec 0c             	sub    $0xc,%esp
801021bd:	ff 75 08             	push   0x8(%ebp)
801021c0:	e8 ea f5 ff ff       	call   801017af <iupdate>
801021c5:	83 c4 10             	add    $0x10,%esp
  }
  return n;
801021c8:	8b 45 14             	mov    0x14(%ebp),%eax
}
801021cb:	c9                   	leave
801021cc:	c3                   	ret

801021cd <namecmp>:
//PAGEBREAK!
// Directories

int
namecmp(const char *s, const char *t)
{
801021cd:	55                   	push   %ebp
801021ce:	89 e5                	mov    %esp,%ebp
801021d0:	83 ec 08             	sub    $0x8,%esp
  return strncmp(s, t, DIRSIZ);
801021d3:	83 ec 04             	sub    $0x4,%esp
801021d6:	6a 0e                	push   $0xe
801021d8:	ff 75 0c             	push   0xc(%ebp)
801021db:	ff 75 08             	push   0x8(%ebp)
801021de:	e8 55 32 00 00       	call   80105438 <strncmp>
801021e3:	83 c4 10             	add    $0x10,%esp
}
801021e6:	c9                   	leave
801021e7:	c3                   	ret

801021e8 <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
801021e8:	55                   	push   %ebp
801021e9:	89 e5                	mov    %esp,%ebp
801021eb:	83 ec 28             	sub    $0x28,%esp
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
801021ee:	8b 45 08             	mov    0x8(%ebp),%eax
801021f1:	0f b7 40 10          	movzwl 0x10(%eax),%eax
801021f5:	66 83 f8 01          	cmp    $0x1,%ax
801021f9:	74 0d                	je     80102208 <dirlookup+0x20>
    panic("dirlookup not DIR");
801021fb:	83 ec 0c             	sub    $0xc,%esp
801021fe:	68 83 89 10 80       	push   $0x80108983
80102203:	e8 71 e3 ff ff       	call   80100579 <panic>

  for(off = 0; off < dp->size; off += sizeof(de)){
80102208:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010220f:	eb 7b                	jmp    8010228c <dirlookup+0xa4>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80102211:	6a 10                	push   $0x10
80102213:	ff 75 f4             	push   -0xc(%ebp)
80102216:	8d 45 e0             	lea    -0x20(%ebp),%eax
80102219:	50                   	push   %eax
8010221a:	ff 75 08             	push   0x8(%ebp)
8010221d:	e8 d0 fc ff ff       	call   80101ef2 <readi>
80102222:	83 c4 10             	add    $0x10,%esp
80102225:	83 f8 10             	cmp    $0x10,%eax
80102228:	74 0d                	je     80102237 <dirlookup+0x4f>
      panic("dirlink read");
8010222a:	83 ec 0c             	sub    $0xc,%esp
8010222d:	68 95 89 10 80       	push   $0x80108995
80102232:	e8 42 e3 ff ff       	call   80100579 <panic>
    if(de.inum == 0)
80102237:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
8010223b:	66 85 c0             	test   %ax,%ax
8010223e:	74 47                	je     80102287 <dirlookup+0x9f>
      continue;
    if(namecmp(name, de.name) == 0){
80102240:	83 ec 08             	sub    $0x8,%esp
80102243:	8d 45 e0             	lea    -0x20(%ebp),%eax
80102246:	83 c0 02             	add    $0x2,%eax
80102249:	50                   	push   %eax
8010224a:	ff 75 0c             	push   0xc(%ebp)
8010224d:	e8 7b ff ff ff       	call   801021cd <namecmp>
80102252:	83 c4 10             	add    $0x10,%esp
80102255:	85 c0                	test   %eax,%eax
80102257:	75 2f                	jne    80102288 <dirlookup+0xa0>
      // entry matches path element
      if(poff)
80102259:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
8010225d:	74 08                	je     80102267 <dirlookup+0x7f>
        *poff = off;
8010225f:	8b 45 10             	mov    0x10(%ebp),%eax
80102262:	8b 55 f4             	mov    -0xc(%ebp),%edx
80102265:	89 10                	mov    %edx,(%eax)
      inum = de.inum;
80102267:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
8010226b:	0f b7 c0             	movzwl %ax,%eax
8010226e:	89 45 f0             	mov    %eax,-0x10(%ebp)
      return iget(dp->dev, inum);
80102271:	8b 45 08             	mov    0x8(%ebp),%eax
80102274:	8b 00                	mov    (%eax),%eax
80102276:	83 ec 08             	sub    $0x8,%esp
80102279:	ff 75 f0             	push   -0x10(%ebp)
8010227c:	50                   	push   %eax
8010227d:	e8 ee f5 ff ff       	call   80101870 <iget>
80102282:	83 c4 10             	add    $0x10,%esp
80102285:	eb 19                	jmp    801022a0 <dirlookup+0xb8>
      continue;
80102287:	90                   	nop
  for(off = 0; off < dp->size; off += sizeof(de)){
80102288:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
8010228c:	8b 45 08             	mov    0x8(%ebp),%eax
8010228f:	8b 40 18             	mov    0x18(%eax),%eax
80102292:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80102295:	0f 82 76 ff ff ff    	jb     80102211 <dirlookup+0x29>
    }
  }

  return 0;
8010229b:	b8 00 00 00 00       	mov    $0x0,%eax
}
801022a0:	c9                   	leave
801022a1:	c3                   	ret

801022a2 <dirlink>:

// Write a new directory entry (name, inum) into the directory dp.
int
dirlink(struct inode *dp, char *name, uint inum)
{
801022a2:	55                   	push   %ebp
801022a3:	89 e5                	mov    %esp,%ebp
801022a5:	83 ec 28             	sub    $0x28,%esp
  int off;
  struct dirent de;
  struct inode *ip;

  // Check that name is not present.
  if((ip = dirlookup(dp, name, 0)) != 0){
801022a8:	83 ec 04             	sub    $0x4,%esp
801022ab:	6a 00                	push   $0x0
801022ad:	ff 75 0c             	push   0xc(%ebp)
801022b0:	ff 75 08             	push   0x8(%ebp)
801022b3:	e8 30 ff ff ff       	call   801021e8 <dirlookup>
801022b8:	83 c4 10             	add    $0x10,%esp
801022bb:	89 45 f0             	mov    %eax,-0x10(%ebp)
801022be:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801022c2:	74 18                	je     801022dc <dirlink+0x3a>
    iput(ip);
801022c4:	83 ec 0c             	sub    $0xc,%esp
801022c7:	ff 75 f0             	push   -0x10(%ebp)
801022ca:	e8 8a f8 ff ff       	call   80101b59 <iput>
801022cf:	83 c4 10             	add    $0x10,%esp
    return -1;
801022d2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801022d7:	e9 9c 00 00 00       	jmp    80102378 <dirlink+0xd6>
  }

  // Look for an empty dirent.
  for(off = 0; off < dp->size; off += sizeof(de)){
801022dc:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801022e3:	eb 39                	jmp    8010231e <dirlink+0x7c>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
801022e5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801022e8:	6a 10                	push   $0x10
801022ea:	50                   	push   %eax
801022eb:	8d 45 e0             	lea    -0x20(%ebp),%eax
801022ee:	50                   	push   %eax
801022ef:	ff 75 08             	push   0x8(%ebp)
801022f2:	e8 fb fb ff ff       	call   80101ef2 <readi>
801022f7:	83 c4 10             	add    $0x10,%esp
801022fa:	83 f8 10             	cmp    $0x10,%eax
801022fd:	74 0d                	je     8010230c <dirlink+0x6a>
      panic("dirlink read");
801022ff:	83 ec 0c             	sub    $0xc,%esp
80102302:	68 95 89 10 80       	push   $0x80108995
80102307:	e8 6d e2 ff ff       	call   80100579 <panic>
    if(de.inum == 0)
8010230c:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
80102310:	66 85 c0             	test   %ax,%ax
80102313:	74 18                	je     8010232d <dirlink+0x8b>
  for(off = 0; off < dp->size; off += sizeof(de)){
80102315:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102318:	83 c0 10             	add    $0x10,%eax
8010231b:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010231e:	8b 45 08             	mov    0x8(%ebp),%eax
80102321:	8b 40 18             	mov    0x18(%eax),%eax
80102324:	8b 55 f4             	mov    -0xc(%ebp),%edx
80102327:	39 c2                	cmp    %eax,%edx
80102329:	72 ba                	jb     801022e5 <dirlink+0x43>
8010232b:	eb 01                	jmp    8010232e <dirlink+0x8c>
      break;
8010232d:	90                   	nop
  }

  strncpy(de.name, name, DIRSIZ);
8010232e:	83 ec 04             	sub    $0x4,%esp
80102331:	6a 0e                	push   $0xe
80102333:	ff 75 0c             	push   0xc(%ebp)
80102336:	8d 45 e0             	lea    -0x20(%ebp),%eax
80102339:	83 c0 02             	add    $0x2,%eax
8010233c:	50                   	push   %eax
8010233d:	e8 4c 31 00 00       	call   8010548e <strncpy>
80102342:	83 c4 10             	add    $0x10,%esp
  de.inum = inum;
80102345:	8b 45 10             	mov    0x10(%ebp),%eax
80102348:	66 89 45 e0          	mov    %ax,-0x20(%ebp)
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
8010234c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010234f:	6a 10                	push   $0x10
80102351:	50                   	push   %eax
80102352:	8d 45 e0             	lea    -0x20(%ebp),%eax
80102355:	50                   	push   %eax
80102356:	ff 75 08             	push   0x8(%ebp)
80102359:	e8 e9 fc ff ff       	call   80102047 <writei>
8010235e:	83 c4 10             	add    $0x10,%esp
80102361:	83 f8 10             	cmp    $0x10,%eax
80102364:	74 0d                	je     80102373 <dirlink+0xd1>
    panic("dirlink");
80102366:	83 ec 0c             	sub    $0xc,%esp
80102369:	68 a2 89 10 80       	push   $0x801089a2
8010236e:	e8 06 e2 ff ff       	call   80100579 <panic>
  
  return 0;
80102373:	b8 00 00 00 00       	mov    $0x0,%eax
}
80102378:	c9                   	leave
80102379:	c3                   	ret

8010237a <skipelem>:
//   skipelem("a", name) = "", setting name = "a"
//   skipelem("", name) = skipelem("////", name) = 0
//
static char*
skipelem(char *path, char *name)
{
8010237a:	55                   	push   %ebp
8010237b:	89 e5                	mov    %esp,%ebp
8010237d:	83 ec 18             	sub    $0x18,%esp
  char *s;
  int len;

  while(*path == '/')
80102380:	eb 04                	jmp    80102386 <skipelem+0xc>
    path++;
80102382:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  while(*path == '/')
80102386:	8b 45 08             	mov    0x8(%ebp),%eax
80102389:	0f b6 00             	movzbl (%eax),%eax
8010238c:	3c 2f                	cmp    $0x2f,%al
8010238e:	74 f2                	je     80102382 <skipelem+0x8>
  if(*path == 0)
80102390:	8b 45 08             	mov    0x8(%ebp),%eax
80102393:	0f b6 00             	movzbl (%eax),%eax
80102396:	84 c0                	test   %al,%al
80102398:	75 07                	jne    801023a1 <skipelem+0x27>
    return 0;
8010239a:	b8 00 00 00 00       	mov    $0x0,%eax
8010239f:	eb 77                	jmp    80102418 <skipelem+0x9e>
  s = path;
801023a1:	8b 45 08             	mov    0x8(%ebp),%eax
801023a4:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(*path != '/' && *path != 0)
801023a7:	eb 04                	jmp    801023ad <skipelem+0x33>
    path++;
801023a9:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  while(*path != '/' && *path != 0)
801023ad:	8b 45 08             	mov    0x8(%ebp),%eax
801023b0:	0f b6 00             	movzbl (%eax),%eax
801023b3:	3c 2f                	cmp    $0x2f,%al
801023b5:	74 0a                	je     801023c1 <skipelem+0x47>
801023b7:	8b 45 08             	mov    0x8(%ebp),%eax
801023ba:	0f b6 00             	movzbl (%eax),%eax
801023bd:	84 c0                	test   %al,%al
801023bf:	75 e8                	jne    801023a9 <skipelem+0x2f>
  len = path - s;
801023c1:	8b 45 08             	mov    0x8(%ebp),%eax
801023c4:	2b 45 f4             	sub    -0xc(%ebp),%eax
801023c7:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(len >= DIRSIZ)
801023ca:	83 7d f0 0d          	cmpl   $0xd,-0x10(%ebp)
801023ce:	7e 15                	jle    801023e5 <skipelem+0x6b>
    memmove(name, s, DIRSIZ);
801023d0:	83 ec 04             	sub    $0x4,%esp
801023d3:	6a 0e                	push   $0xe
801023d5:	ff 75 f4             	push   -0xc(%ebp)
801023d8:	ff 75 0c             	push   0xc(%ebp)
801023db:	e8 c2 2f 00 00       	call   801053a2 <memmove>
801023e0:	83 c4 10             	add    $0x10,%esp
801023e3:	eb 26                	jmp    8010240b <skipelem+0x91>
  else {
    memmove(name, s, len);
801023e5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801023e8:	83 ec 04             	sub    $0x4,%esp
801023eb:	50                   	push   %eax
801023ec:	ff 75 f4             	push   -0xc(%ebp)
801023ef:	ff 75 0c             	push   0xc(%ebp)
801023f2:	e8 ab 2f 00 00       	call   801053a2 <memmove>
801023f7:	83 c4 10             	add    $0x10,%esp
    name[len] = 0;
801023fa:	8b 55 f0             	mov    -0x10(%ebp),%edx
801023fd:	8b 45 0c             	mov    0xc(%ebp),%eax
80102400:	01 d0                	add    %edx,%eax
80102402:	c6 00 00             	movb   $0x0,(%eax)
  }
  while(*path == '/')
80102405:	eb 04                	jmp    8010240b <skipelem+0x91>
    path++;
80102407:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  while(*path == '/')
8010240b:	8b 45 08             	mov    0x8(%ebp),%eax
8010240e:	0f b6 00             	movzbl (%eax),%eax
80102411:	3c 2f                	cmp    $0x2f,%al
80102413:	74 f2                	je     80102407 <skipelem+0x8d>
  return path;
80102415:	8b 45 08             	mov    0x8(%ebp),%eax
}
80102418:	c9                   	leave
80102419:	c3                   	ret

8010241a <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
8010241a:	55                   	push   %ebp
8010241b:	89 e5                	mov    %esp,%ebp
8010241d:	83 ec 18             	sub    $0x18,%esp
  struct inode *ip, *next;

  if(*path == '/')
80102420:	8b 45 08             	mov    0x8(%ebp),%eax
80102423:	0f b6 00             	movzbl (%eax),%eax
80102426:	3c 2f                	cmp    $0x2f,%al
80102428:	75 17                	jne    80102441 <namex+0x27>
    ip = iget(ROOTDEV, ROOTINO);
8010242a:	83 ec 08             	sub    $0x8,%esp
8010242d:	6a 01                	push   $0x1
8010242f:	6a 01                	push   $0x1
80102431:	e8 3a f4 ff ff       	call   80101870 <iget>
80102436:	83 c4 10             	add    $0x10,%esp
80102439:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010243c:	e9 bb 00 00 00       	jmp    801024fc <namex+0xe2>
  else
    ip = idup(proc->cwd);
80102441:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80102447:	8b 40 68             	mov    0x68(%eax),%eax
8010244a:	83 ec 0c             	sub    $0xc,%esp
8010244d:	50                   	push   %eax
8010244e:	e8 fc f4 ff ff       	call   8010194f <idup>
80102453:	83 c4 10             	add    $0x10,%esp
80102456:	89 45 f4             	mov    %eax,-0xc(%ebp)

  while((path = skipelem(path, name)) != 0){
80102459:	e9 9e 00 00 00       	jmp    801024fc <namex+0xe2>
    ilock(ip);
8010245e:	83 ec 0c             	sub    $0xc,%esp
80102461:	ff 75 f4             	push   -0xc(%ebp)
80102464:	e8 20 f5 ff ff       	call   80101989 <ilock>
80102469:	83 c4 10             	add    $0x10,%esp
    if(ip->type != T_DIR){
8010246c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010246f:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80102473:	66 83 f8 01          	cmp    $0x1,%ax
80102477:	74 18                	je     80102491 <namex+0x77>
      iunlockput(ip);
80102479:	83 ec 0c             	sub    $0xc,%esp
8010247c:	ff 75 f4             	push   -0xc(%ebp)
8010247f:	e8 c5 f7 ff ff       	call   80101c49 <iunlockput>
80102484:	83 c4 10             	add    $0x10,%esp
      return 0;
80102487:	b8 00 00 00 00       	mov    $0x0,%eax
8010248c:	e9 a7 00 00 00       	jmp    80102538 <namex+0x11e>
    }
    if(nameiparent && *path == '\0'){
80102491:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80102495:	74 20                	je     801024b7 <namex+0x9d>
80102497:	8b 45 08             	mov    0x8(%ebp),%eax
8010249a:	0f b6 00             	movzbl (%eax),%eax
8010249d:	84 c0                	test   %al,%al
8010249f:	75 16                	jne    801024b7 <namex+0x9d>
      // Stop one level early.
      iunlock(ip);
801024a1:	83 ec 0c             	sub    $0xc,%esp
801024a4:	ff 75 f4             	push   -0xc(%ebp)
801024a7:	e8 3b f6 ff ff       	call   80101ae7 <iunlock>
801024ac:	83 c4 10             	add    $0x10,%esp
      return ip;
801024af:	8b 45 f4             	mov    -0xc(%ebp),%eax
801024b2:	e9 81 00 00 00       	jmp    80102538 <namex+0x11e>
    }
    if((next = dirlookup(ip, name, 0)) == 0){
801024b7:	83 ec 04             	sub    $0x4,%esp
801024ba:	6a 00                	push   $0x0
801024bc:	ff 75 10             	push   0x10(%ebp)
801024bf:	ff 75 f4             	push   -0xc(%ebp)
801024c2:	e8 21 fd ff ff       	call   801021e8 <dirlookup>
801024c7:	83 c4 10             	add    $0x10,%esp
801024ca:	89 45 f0             	mov    %eax,-0x10(%ebp)
801024cd:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801024d1:	75 15                	jne    801024e8 <namex+0xce>
      iunlockput(ip);
801024d3:	83 ec 0c             	sub    $0xc,%esp
801024d6:	ff 75 f4             	push   -0xc(%ebp)
801024d9:	e8 6b f7 ff ff       	call   80101c49 <iunlockput>
801024de:	83 c4 10             	add    $0x10,%esp
      return 0;
801024e1:	b8 00 00 00 00       	mov    $0x0,%eax
801024e6:	eb 50                	jmp    80102538 <namex+0x11e>
    }
    iunlockput(ip);
801024e8:	83 ec 0c             	sub    $0xc,%esp
801024eb:	ff 75 f4             	push   -0xc(%ebp)
801024ee:	e8 56 f7 ff ff       	call   80101c49 <iunlockput>
801024f3:	83 c4 10             	add    $0x10,%esp
    ip = next;
801024f6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801024f9:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while((path = skipelem(path, name)) != 0){
801024fc:	83 ec 08             	sub    $0x8,%esp
801024ff:	ff 75 10             	push   0x10(%ebp)
80102502:	ff 75 08             	push   0x8(%ebp)
80102505:	e8 70 fe ff ff       	call   8010237a <skipelem>
8010250a:	83 c4 10             	add    $0x10,%esp
8010250d:	89 45 08             	mov    %eax,0x8(%ebp)
80102510:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80102514:	0f 85 44 ff ff ff    	jne    8010245e <namex+0x44>
  }
  if(nameiparent){
8010251a:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
8010251e:	74 15                	je     80102535 <namex+0x11b>
    iput(ip);
80102520:	83 ec 0c             	sub    $0xc,%esp
80102523:	ff 75 f4             	push   -0xc(%ebp)
80102526:	e8 2e f6 ff ff       	call   80101b59 <iput>
8010252b:	83 c4 10             	add    $0x10,%esp
    return 0;
8010252e:	b8 00 00 00 00       	mov    $0x0,%eax
80102533:	eb 03                	jmp    80102538 <namex+0x11e>
  }
  return ip;
80102535:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80102538:	c9                   	leave
80102539:	c3                   	ret

8010253a <namei>:

struct inode*
namei(char *path)
{
8010253a:	55                   	push   %ebp
8010253b:	89 e5                	mov    %esp,%ebp
8010253d:	83 ec 18             	sub    $0x18,%esp
  char name[DIRSIZ];
  return namex(path, 0, name);
80102540:	83 ec 04             	sub    $0x4,%esp
80102543:	8d 45 ea             	lea    -0x16(%ebp),%eax
80102546:	50                   	push   %eax
80102547:	6a 00                	push   $0x0
80102549:	ff 75 08             	push   0x8(%ebp)
8010254c:	e8 c9 fe ff ff       	call   8010241a <namex>
80102551:	83 c4 10             	add    $0x10,%esp
}
80102554:	c9                   	leave
80102555:	c3                   	ret

80102556 <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
80102556:	55                   	push   %ebp
80102557:	89 e5                	mov    %esp,%ebp
80102559:	83 ec 08             	sub    $0x8,%esp
  return namex(path, 1, name);
8010255c:	83 ec 04             	sub    $0x4,%esp
8010255f:	ff 75 0c             	push   0xc(%ebp)
80102562:	6a 01                	push   $0x1
80102564:	ff 75 08             	push   0x8(%ebp)
80102567:	e8 ae fe ff ff       	call   8010241a <namex>
8010256c:	83 c4 10             	add    $0x10,%esp
}
8010256f:	c9                   	leave
80102570:	c3                   	ret

80102571 <inb>:
{
80102571:	55                   	push   %ebp
80102572:	89 e5                	mov    %esp,%ebp
80102574:	83 ec 14             	sub    $0x14,%esp
80102577:	8b 45 08             	mov    0x8(%ebp),%eax
8010257a:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
8010257e:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80102582:	89 c2                	mov    %eax,%edx
80102584:	ec                   	in     (%dx),%al
80102585:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80102588:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
8010258c:	c9                   	leave
8010258d:	c3                   	ret

8010258e <insl>:
{
8010258e:	55                   	push   %ebp
8010258f:	89 e5                	mov    %esp,%ebp
80102591:	57                   	push   %edi
80102592:	53                   	push   %ebx
  asm volatile("cld; rep insl" :
80102593:	8b 55 08             	mov    0x8(%ebp),%edx
80102596:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80102599:	8b 45 10             	mov    0x10(%ebp),%eax
8010259c:	89 cb                	mov    %ecx,%ebx
8010259e:	89 df                	mov    %ebx,%edi
801025a0:	89 c1                	mov    %eax,%ecx
801025a2:	fc                   	cld
801025a3:	f3 6d                	rep insl (%dx),%es:(%edi)
801025a5:	89 c8                	mov    %ecx,%eax
801025a7:	89 fb                	mov    %edi,%ebx
801025a9:	89 5d 0c             	mov    %ebx,0xc(%ebp)
801025ac:	89 45 10             	mov    %eax,0x10(%ebp)
}
801025af:	90                   	nop
801025b0:	5b                   	pop    %ebx
801025b1:	5f                   	pop    %edi
801025b2:	5d                   	pop    %ebp
801025b3:	c3                   	ret

801025b4 <outb>:
{
801025b4:	55                   	push   %ebp
801025b5:	89 e5                	mov    %esp,%ebp
801025b7:	83 ec 08             	sub    $0x8,%esp
801025ba:	8b 55 08             	mov    0x8(%ebp),%edx
801025bd:	8b 45 0c             	mov    0xc(%ebp),%eax
801025c0:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
801025c4:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
801025c7:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
801025cb:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
801025cf:	ee                   	out    %al,(%dx)
}
801025d0:	90                   	nop
801025d1:	c9                   	leave
801025d2:	c3                   	ret

801025d3 <outsl>:
{
801025d3:	55                   	push   %ebp
801025d4:	89 e5                	mov    %esp,%ebp
801025d6:	56                   	push   %esi
801025d7:	53                   	push   %ebx
  asm volatile("cld; rep outsl" :
801025d8:	8b 55 08             	mov    0x8(%ebp),%edx
801025db:	8b 4d 0c             	mov    0xc(%ebp),%ecx
801025de:	8b 45 10             	mov    0x10(%ebp),%eax
801025e1:	89 cb                	mov    %ecx,%ebx
801025e3:	89 de                	mov    %ebx,%esi
801025e5:	89 c1                	mov    %eax,%ecx
801025e7:	fc                   	cld
801025e8:	f3 6f                	rep outsl %ds:(%esi),(%dx)
801025ea:	89 c8                	mov    %ecx,%eax
801025ec:	89 f3                	mov    %esi,%ebx
801025ee:	89 5d 0c             	mov    %ebx,0xc(%ebp)
801025f1:	89 45 10             	mov    %eax,0x10(%ebp)
}
801025f4:	90                   	nop
801025f5:	5b                   	pop    %ebx
801025f6:	5e                   	pop    %esi
801025f7:	5d                   	pop    %ebp
801025f8:	c3                   	ret

801025f9 <idewait>:
static void idestart(struct buf*);

// Wait for IDE disk to become ready.
static int
idewait(int checkerr)
{
801025f9:	55                   	push   %ebp
801025fa:	89 e5                	mov    %esp,%ebp
801025fc:	83 ec 10             	sub    $0x10,%esp
  int r;

  while(((r = inb(0x1f7)) & (IDE_BSY|IDE_DRDY)) != IDE_DRDY) 
801025ff:	90                   	nop
80102600:	68 f7 01 00 00       	push   $0x1f7
80102605:	e8 67 ff ff ff       	call   80102571 <inb>
8010260a:	83 c4 04             	add    $0x4,%esp
8010260d:	0f b6 c0             	movzbl %al,%eax
80102610:	89 45 fc             	mov    %eax,-0x4(%ebp)
80102613:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102616:	25 c0 00 00 00       	and    $0xc0,%eax
8010261b:	83 f8 40             	cmp    $0x40,%eax
8010261e:	75 e0                	jne    80102600 <idewait+0x7>
    ;
  if(checkerr && (r & (IDE_DF|IDE_ERR)) != 0)
80102620:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80102624:	74 11                	je     80102637 <idewait+0x3e>
80102626:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102629:	83 e0 21             	and    $0x21,%eax
8010262c:	85 c0                	test   %eax,%eax
8010262e:	74 07                	je     80102637 <idewait+0x3e>
    return -1;
80102630:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102635:	eb 05                	jmp    8010263c <idewait+0x43>
  return 0;
80102637:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010263c:	c9                   	leave
8010263d:	c3                   	ret

8010263e <ideinit>:

void
ideinit(void)
{
8010263e:	55                   	push   %ebp
8010263f:	89 e5                	mov    %esp,%ebp
80102641:	83 ec 18             	sub    $0x18,%esp
  int i;
  
  initlock(&idelock, "ide");
80102644:	83 ec 08             	sub    $0x8,%esp
80102647:	68 aa 89 10 80       	push   $0x801089aa
8010264c:	68 c0 11 11 80       	push   $0x801111c0
80102651:	e8 07 2a 00 00       	call   8010505d <initlock>
80102656:	83 c4 10             	add    $0x10,%esp
  picenable(IRQ_IDE);
80102659:	83 ec 0c             	sub    $0xc,%esp
8010265c:	6a 0e                	push   $0xe
8010265e:	e8 05 19 00 00       	call   80103f68 <picenable>
80102663:	83 c4 10             	add    $0x10,%esp
  ioapicenable(IRQ_IDE, ncpu - 1);
80102666:	a1 44 19 11 80       	mov    0x80111944,%eax
8010266b:	83 e8 01             	sub    $0x1,%eax
8010266e:	83 ec 08             	sub    $0x8,%esp
80102671:	50                   	push   %eax
80102672:	6a 0e                	push   $0xe
80102674:	e8 73 04 00 00       	call   80102aec <ioapicenable>
80102679:	83 c4 10             	add    $0x10,%esp
  idewait(0);
8010267c:	83 ec 0c             	sub    $0xc,%esp
8010267f:	6a 00                	push   $0x0
80102681:	e8 73 ff ff ff       	call   801025f9 <idewait>
80102686:	83 c4 10             	add    $0x10,%esp
  
  // Check if disk 1 is present
  outb(0x1f6, 0xe0 | (1<<4));
80102689:	83 ec 08             	sub    $0x8,%esp
8010268c:	68 f0 00 00 00       	push   $0xf0
80102691:	68 f6 01 00 00       	push   $0x1f6
80102696:	e8 19 ff ff ff       	call   801025b4 <outb>
8010269b:	83 c4 10             	add    $0x10,%esp
  for(i=0; i<1000; i++){
8010269e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801026a5:	eb 24                	jmp    801026cb <ideinit+0x8d>
    if(inb(0x1f7) != 0){
801026a7:	83 ec 0c             	sub    $0xc,%esp
801026aa:	68 f7 01 00 00       	push   $0x1f7
801026af:	e8 bd fe ff ff       	call   80102571 <inb>
801026b4:	83 c4 10             	add    $0x10,%esp
801026b7:	84 c0                	test   %al,%al
801026b9:	74 0c                	je     801026c7 <ideinit+0x89>
      havedisk1 = 1;
801026bb:	c7 05 f8 11 11 80 01 	movl   $0x1,0x801111f8
801026c2:	00 00 00 
      break;
801026c5:	eb 0d                	jmp    801026d4 <ideinit+0x96>
  for(i=0; i<1000; i++){
801026c7:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801026cb:	81 7d f4 e7 03 00 00 	cmpl   $0x3e7,-0xc(%ebp)
801026d2:	7e d3                	jle    801026a7 <ideinit+0x69>
    }
  }
  
  // Switch back to disk 0.
  outb(0x1f6, 0xe0 | (0<<4));
801026d4:	83 ec 08             	sub    $0x8,%esp
801026d7:	68 e0 00 00 00       	push   $0xe0
801026dc:	68 f6 01 00 00       	push   $0x1f6
801026e1:	e8 ce fe ff ff       	call   801025b4 <outb>
801026e6:	83 c4 10             	add    $0x10,%esp
}
801026e9:	90                   	nop
801026ea:	c9                   	leave
801026eb:	c3                   	ret

801026ec <idestart>:

// Start the request for b.  Caller must hold idelock.
static void
idestart(struct buf *b)
{
801026ec:	55                   	push   %ebp
801026ed:	89 e5                	mov    %esp,%ebp
801026ef:	83 ec 18             	sub    $0x18,%esp
  if(b == 0)
801026f2:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801026f6:	75 0d                	jne    80102705 <idestart+0x19>
    panic("idestart");
801026f8:	83 ec 0c             	sub    $0xc,%esp
801026fb:	68 ae 89 10 80       	push   $0x801089ae
80102700:	e8 74 de ff ff       	call   80100579 <panic>
  if(b->blockno >= FSSIZE)
80102705:	8b 45 08             	mov    0x8(%ebp),%eax
80102708:	8b 40 08             	mov    0x8(%eax),%eax
8010270b:	3d e7 03 00 00       	cmp    $0x3e7,%eax
80102710:	76 0d                	jbe    8010271f <idestart+0x33>
    panic("incorrect blockno");
80102712:	83 ec 0c             	sub    $0xc,%esp
80102715:	68 b7 89 10 80       	push   $0x801089b7
8010271a:	e8 5a de ff ff       	call   80100579 <panic>
  int sector_per_block =  BSIZE/SECTOR_SIZE;
8010271f:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
  int sector = b->blockno * sector_per_block;
80102726:	8b 45 08             	mov    0x8(%ebp),%eax
80102729:	8b 50 08             	mov    0x8(%eax),%edx
8010272c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010272f:	0f af c2             	imul   %edx,%eax
80102732:	89 45 f0             	mov    %eax,-0x10(%ebp)

  if (sector_per_block > 7) panic("idestart");
80102735:	83 7d f4 07          	cmpl   $0x7,-0xc(%ebp)
80102739:	7e 0d                	jle    80102748 <idestart+0x5c>
8010273b:	83 ec 0c             	sub    $0xc,%esp
8010273e:	68 ae 89 10 80       	push   $0x801089ae
80102743:	e8 31 de ff ff       	call   80100579 <panic>
  
  idewait(0);
80102748:	83 ec 0c             	sub    $0xc,%esp
8010274b:	6a 00                	push   $0x0
8010274d:	e8 a7 fe ff ff       	call   801025f9 <idewait>
80102752:	83 c4 10             	add    $0x10,%esp
  outb(0x3f6, 0);  // generate interrupt
80102755:	83 ec 08             	sub    $0x8,%esp
80102758:	6a 00                	push   $0x0
8010275a:	68 f6 03 00 00       	push   $0x3f6
8010275f:	e8 50 fe ff ff       	call   801025b4 <outb>
80102764:	83 c4 10             	add    $0x10,%esp
  outb(0x1f2, sector_per_block);  // number of sectors
80102767:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010276a:	0f b6 c0             	movzbl %al,%eax
8010276d:	83 ec 08             	sub    $0x8,%esp
80102770:	50                   	push   %eax
80102771:	68 f2 01 00 00       	push   $0x1f2
80102776:	e8 39 fe ff ff       	call   801025b4 <outb>
8010277b:	83 c4 10             	add    $0x10,%esp
  outb(0x1f3, sector & 0xff);
8010277e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102781:	0f b6 c0             	movzbl %al,%eax
80102784:	83 ec 08             	sub    $0x8,%esp
80102787:	50                   	push   %eax
80102788:	68 f3 01 00 00       	push   $0x1f3
8010278d:	e8 22 fe ff ff       	call   801025b4 <outb>
80102792:	83 c4 10             	add    $0x10,%esp
  outb(0x1f4, (sector >> 8) & 0xff);
80102795:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102798:	c1 f8 08             	sar    $0x8,%eax
8010279b:	0f b6 c0             	movzbl %al,%eax
8010279e:	83 ec 08             	sub    $0x8,%esp
801027a1:	50                   	push   %eax
801027a2:	68 f4 01 00 00       	push   $0x1f4
801027a7:	e8 08 fe ff ff       	call   801025b4 <outb>
801027ac:	83 c4 10             	add    $0x10,%esp
  outb(0x1f5, (sector >> 16) & 0xff);
801027af:	8b 45 f0             	mov    -0x10(%ebp),%eax
801027b2:	c1 f8 10             	sar    $0x10,%eax
801027b5:	0f b6 c0             	movzbl %al,%eax
801027b8:	83 ec 08             	sub    $0x8,%esp
801027bb:	50                   	push   %eax
801027bc:	68 f5 01 00 00       	push   $0x1f5
801027c1:	e8 ee fd ff ff       	call   801025b4 <outb>
801027c6:	83 c4 10             	add    $0x10,%esp
  outb(0x1f6, 0xe0 | ((b->dev&1)<<4) | ((sector>>24)&0x0f));
801027c9:	8b 45 08             	mov    0x8(%ebp),%eax
801027cc:	8b 40 04             	mov    0x4(%eax),%eax
801027cf:	c1 e0 04             	shl    $0x4,%eax
801027d2:	83 e0 10             	and    $0x10,%eax
801027d5:	89 c2                	mov    %eax,%edx
801027d7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801027da:	c1 f8 18             	sar    $0x18,%eax
801027dd:	83 e0 0f             	and    $0xf,%eax
801027e0:	09 d0                	or     %edx,%eax
801027e2:	83 c8 e0             	or     $0xffffffe0,%eax
801027e5:	0f b6 c0             	movzbl %al,%eax
801027e8:	83 ec 08             	sub    $0x8,%esp
801027eb:	50                   	push   %eax
801027ec:	68 f6 01 00 00       	push   $0x1f6
801027f1:	e8 be fd ff ff       	call   801025b4 <outb>
801027f6:	83 c4 10             	add    $0x10,%esp
  if(b->flags & B_DIRTY){
801027f9:	8b 45 08             	mov    0x8(%ebp),%eax
801027fc:	8b 00                	mov    (%eax),%eax
801027fe:	83 e0 04             	and    $0x4,%eax
80102801:	85 c0                	test   %eax,%eax
80102803:	74 30                	je     80102835 <idestart+0x149>
    outb(0x1f7, IDE_CMD_WRITE);
80102805:	83 ec 08             	sub    $0x8,%esp
80102808:	6a 30                	push   $0x30
8010280a:	68 f7 01 00 00       	push   $0x1f7
8010280f:	e8 a0 fd ff ff       	call   801025b4 <outb>
80102814:	83 c4 10             	add    $0x10,%esp
    outsl(0x1f0, b->data, BSIZE/4);
80102817:	8b 45 08             	mov    0x8(%ebp),%eax
8010281a:	83 c0 18             	add    $0x18,%eax
8010281d:	83 ec 04             	sub    $0x4,%esp
80102820:	68 80 00 00 00       	push   $0x80
80102825:	50                   	push   %eax
80102826:	68 f0 01 00 00       	push   $0x1f0
8010282b:	e8 a3 fd ff ff       	call   801025d3 <outsl>
80102830:	83 c4 10             	add    $0x10,%esp
  } else {
    outb(0x1f7, IDE_CMD_READ);
  }
}
80102833:	eb 12                	jmp    80102847 <idestart+0x15b>
    outb(0x1f7, IDE_CMD_READ);
80102835:	83 ec 08             	sub    $0x8,%esp
80102838:	6a 20                	push   $0x20
8010283a:	68 f7 01 00 00       	push   $0x1f7
8010283f:	e8 70 fd ff ff       	call   801025b4 <outb>
80102844:	83 c4 10             	add    $0x10,%esp
}
80102847:	90                   	nop
80102848:	c9                   	leave
80102849:	c3                   	ret

8010284a <ideintr>:

// Interrupt handler.
void
ideintr(void)
{
8010284a:	55                   	push   %ebp
8010284b:	89 e5                	mov    %esp,%ebp
8010284d:	83 ec 18             	sub    $0x18,%esp
  struct buf *b;

  // First queued buffer is the active request.
  acquire(&idelock);
80102850:	83 ec 0c             	sub    $0xc,%esp
80102853:	68 c0 11 11 80       	push   $0x801111c0
80102858:	e8 22 28 00 00       	call   8010507f <acquire>
8010285d:	83 c4 10             	add    $0x10,%esp
  if((b = idequeue) == 0){
80102860:	a1 f4 11 11 80       	mov    0x801111f4,%eax
80102865:	89 45 f4             	mov    %eax,-0xc(%ebp)
80102868:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010286c:	75 15                	jne    80102883 <ideintr+0x39>
    release(&idelock);
8010286e:	83 ec 0c             	sub    $0xc,%esp
80102871:	68 c0 11 11 80       	push   $0x801111c0
80102876:	e8 6b 28 00 00       	call   801050e6 <release>
8010287b:	83 c4 10             	add    $0x10,%esp
    // cprintf("spurious IDE interrupt\n");
    return;
8010287e:	e9 9a 00 00 00       	jmp    8010291d <ideintr+0xd3>
  }
  idequeue = b->qnext;
80102883:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102886:	8b 40 14             	mov    0x14(%eax),%eax
80102889:	a3 f4 11 11 80       	mov    %eax,0x801111f4

  // Read data if needed.
  if(!(b->flags & B_DIRTY) && idewait(1) >= 0)
8010288e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102891:	8b 00                	mov    (%eax),%eax
80102893:	83 e0 04             	and    $0x4,%eax
80102896:	85 c0                	test   %eax,%eax
80102898:	75 2d                	jne    801028c7 <ideintr+0x7d>
8010289a:	83 ec 0c             	sub    $0xc,%esp
8010289d:	6a 01                	push   $0x1
8010289f:	e8 55 fd ff ff       	call   801025f9 <idewait>
801028a4:	83 c4 10             	add    $0x10,%esp
801028a7:	85 c0                	test   %eax,%eax
801028a9:	78 1c                	js     801028c7 <ideintr+0x7d>
    insl(0x1f0, b->data, BSIZE/4);
801028ab:	8b 45 f4             	mov    -0xc(%ebp),%eax
801028ae:	83 c0 18             	add    $0x18,%eax
801028b1:	83 ec 04             	sub    $0x4,%esp
801028b4:	68 80 00 00 00       	push   $0x80
801028b9:	50                   	push   %eax
801028ba:	68 f0 01 00 00       	push   $0x1f0
801028bf:	e8 ca fc ff ff       	call   8010258e <insl>
801028c4:	83 c4 10             	add    $0x10,%esp
  
  // Wake process waiting for this buf.
  b->flags |= B_VALID;
801028c7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801028ca:	8b 00                	mov    (%eax),%eax
801028cc:	83 c8 02             	or     $0x2,%eax
801028cf:	89 c2                	mov    %eax,%edx
801028d1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801028d4:	89 10                	mov    %edx,(%eax)
  b->flags &= ~B_DIRTY;
801028d6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801028d9:	8b 00                	mov    (%eax),%eax
801028db:	83 e0 fb             	and    $0xfffffffb,%eax
801028de:	89 c2                	mov    %eax,%edx
801028e0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801028e3:	89 10                	mov    %edx,(%eax)
  wakeup(b);
801028e5:	83 ec 0c             	sub    $0xc,%esp
801028e8:	ff 75 f4             	push   -0xc(%ebp)
801028eb:	e8 80 25 00 00       	call   80104e70 <wakeup>
801028f0:	83 c4 10             	add    $0x10,%esp
  
  // Start disk on next buf in queue.
  if(idequeue != 0)
801028f3:	a1 f4 11 11 80       	mov    0x801111f4,%eax
801028f8:	85 c0                	test   %eax,%eax
801028fa:	74 11                	je     8010290d <ideintr+0xc3>
    idestart(idequeue);
801028fc:	a1 f4 11 11 80       	mov    0x801111f4,%eax
80102901:	83 ec 0c             	sub    $0xc,%esp
80102904:	50                   	push   %eax
80102905:	e8 e2 fd ff ff       	call   801026ec <idestart>
8010290a:	83 c4 10             	add    $0x10,%esp

  release(&idelock);
8010290d:	83 ec 0c             	sub    $0xc,%esp
80102910:	68 c0 11 11 80       	push   $0x801111c0
80102915:	e8 cc 27 00 00       	call   801050e6 <release>
8010291a:	83 c4 10             	add    $0x10,%esp
}
8010291d:	c9                   	leave
8010291e:	c3                   	ret

8010291f <iderw>:
// Sync buf with disk. 
// If B_DIRTY is set, write buf to disk, clear B_DIRTY, set B_VALID.
// Else if B_VALID is not set, read buf from disk, set B_VALID.
void
iderw(struct buf *b)
{
8010291f:	55                   	push   %ebp
80102920:	89 e5                	mov    %esp,%ebp
80102922:	83 ec 18             	sub    $0x18,%esp
  struct buf **pp;

  if(!(b->flags & B_BUSY))
80102925:	8b 45 08             	mov    0x8(%ebp),%eax
80102928:	8b 00                	mov    (%eax),%eax
8010292a:	83 e0 01             	and    $0x1,%eax
8010292d:	85 c0                	test   %eax,%eax
8010292f:	75 0d                	jne    8010293e <iderw+0x1f>
    panic("iderw: buf not busy");
80102931:	83 ec 0c             	sub    $0xc,%esp
80102934:	68 c9 89 10 80       	push   $0x801089c9
80102939:	e8 3b dc ff ff       	call   80100579 <panic>
  if((b->flags & (B_VALID|B_DIRTY)) == B_VALID)
8010293e:	8b 45 08             	mov    0x8(%ebp),%eax
80102941:	8b 00                	mov    (%eax),%eax
80102943:	83 e0 06             	and    $0x6,%eax
80102946:	83 f8 02             	cmp    $0x2,%eax
80102949:	75 0d                	jne    80102958 <iderw+0x39>
    panic("iderw: nothing to do");
8010294b:	83 ec 0c             	sub    $0xc,%esp
8010294e:	68 dd 89 10 80       	push   $0x801089dd
80102953:	e8 21 dc ff ff       	call   80100579 <panic>
  if(b->dev != 0 && !havedisk1)
80102958:	8b 45 08             	mov    0x8(%ebp),%eax
8010295b:	8b 40 04             	mov    0x4(%eax),%eax
8010295e:	85 c0                	test   %eax,%eax
80102960:	74 16                	je     80102978 <iderw+0x59>
80102962:	a1 f8 11 11 80       	mov    0x801111f8,%eax
80102967:	85 c0                	test   %eax,%eax
80102969:	75 0d                	jne    80102978 <iderw+0x59>
    panic("iderw: ide disk 1 not present");
8010296b:	83 ec 0c             	sub    $0xc,%esp
8010296e:	68 f2 89 10 80       	push   $0x801089f2
80102973:	e8 01 dc ff ff       	call   80100579 <panic>

  acquire(&idelock);  //DOC:acquire-lock
80102978:	83 ec 0c             	sub    $0xc,%esp
8010297b:	68 c0 11 11 80       	push   $0x801111c0
80102980:	e8 fa 26 00 00       	call   8010507f <acquire>
80102985:	83 c4 10             	add    $0x10,%esp

  // Append b to idequeue.
  b->qnext = 0;
80102988:	8b 45 08             	mov    0x8(%ebp),%eax
8010298b:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
  for(pp=&idequeue; *pp; pp=&(*pp)->qnext)  //DOC:insert-queue
80102992:	c7 45 f4 f4 11 11 80 	movl   $0x801111f4,-0xc(%ebp)
80102999:	eb 0b                	jmp    801029a6 <iderw+0x87>
8010299b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010299e:	8b 00                	mov    (%eax),%eax
801029a0:	83 c0 14             	add    $0x14,%eax
801029a3:	89 45 f4             	mov    %eax,-0xc(%ebp)
801029a6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801029a9:	8b 00                	mov    (%eax),%eax
801029ab:	85 c0                	test   %eax,%eax
801029ad:	75 ec                	jne    8010299b <iderw+0x7c>
    ;
  *pp = b;
801029af:	8b 45 f4             	mov    -0xc(%ebp),%eax
801029b2:	8b 55 08             	mov    0x8(%ebp),%edx
801029b5:	89 10                	mov    %edx,(%eax)
  
  // Start disk if necessary.
  if(idequeue == b)
801029b7:	a1 f4 11 11 80       	mov    0x801111f4,%eax
801029bc:	39 45 08             	cmp    %eax,0x8(%ebp)
801029bf:	75 23                	jne    801029e4 <iderw+0xc5>
    idestart(b);
801029c1:	83 ec 0c             	sub    $0xc,%esp
801029c4:	ff 75 08             	push   0x8(%ebp)
801029c7:	e8 20 fd ff ff       	call   801026ec <idestart>
801029cc:	83 c4 10             	add    $0x10,%esp
  
  // Wait for request to finish.
  while((b->flags & (B_VALID|B_DIRTY)) != B_VALID){
801029cf:	eb 13                	jmp    801029e4 <iderw+0xc5>
    sleep(b, &idelock);
801029d1:	83 ec 08             	sub    $0x8,%esp
801029d4:	68 c0 11 11 80       	push   $0x801111c0
801029d9:	ff 75 08             	push   0x8(%ebp)
801029dc:	e8 a3 23 00 00       	call   80104d84 <sleep>
801029e1:	83 c4 10             	add    $0x10,%esp
  while((b->flags & (B_VALID|B_DIRTY)) != B_VALID){
801029e4:	8b 45 08             	mov    0x8(%ebp),%eax
801029e7:	8b 00                	mov    (%eax),%eax
801029e9:	83 e0 06             	and    $0x6,%eax
801029ec:	83 f8 02             	cmp    $0x2,%eax
801029ef:	75 e0                	jne    801029d1 <iderw+0xb2>
  }

  release(&idelock);
801029f1:	83 ec 0c             	sub    $0xc,%esp
801029f4:	68 c0 11 11 80       	push   $0x801111c0
801029f9:	e8 e8 26 00 00       	call   801050e6 <release>
801029fe:	83 c4 10             	add    $0x10,%esp
}
80102a01:	90                   	nop
80102a02:	c9                   	leave
80102a03:	c3                   	ret

80102a04 <ioapicread>:
  uint data;
};

static uint
ioapicread(int reg)
{
80102a04:	55                   	push   %ebp
80102a05:	89 e5                	mov    %esp,%ebp
  ioapic->reg = reg;
80102a07:	a1 fc 11 11 80       	mov    0x801111fc,%eax
80102a0c:	8b 55 08             	mov    0x8(%ebp),%edx
80102a0f:	89 10                	mov    %edx,(%eax)
  return ioapic->data;
80102a11:	a1 fc 11 11 80       	mov    0x801111fc,%eax
80102a16:	8b 40 10             	mov    0x10(%eax),%eax
}
80102a19:	5d                   	pop    %ebp
80102a1a:	c3                   	ret

80102a1b <ioapicwrite>:

static void
ioapicwrite(int reg, uint data)
{
80102a1b:	55                   	push   %ebp
80102a1c:	89 e5                	mov    %esp,%ebp
  ioapic->reg = reg;
80102a1e:	a1 fc 11 11 80       	mov    0x801111fc,%eax
80102a23:	8b 55 08             	mov    0x8(%ebp),%edx
80102a26:	89 10                	mov    %edx,(%eax)
  ioapic->data = data;
80102a28:	a1 fc 11 11 80       	mov    0x801111fc,%eax
80102a2d:	8b 55 0c             	mov    0xc(%ebp),%edx
80102a30:	89 50 10             	mov    %edx,0x10(%eax)
}
80102a33:	90                   	nop
80102a34:	5d                   	pop    %ebp
80102a35:	c3                   	ret

80102a36 <ioapicinit>:

void
ioapicinit(void)
{
80102a36:	55                   	push   %ebp
80102a37:	89 e5                	mov    %esp,%ebp
80102a39:	83 ec 18             	sub    $0x18,%esp
  int i, id, maxintr;

  if(!ismp)
80102a3c:	a1 40 19 11 80       	mov    0x80111940,%eax
80102a41:	85 c0                	test   %eax,%eax
80102a43:	0f 84 a0 00 00 00    	je     80102ae9 <ioapicinit+0xb3>
    return;

  ioapic = (volatile struct ioapic*)IOAPIC;
80102a49:	c7 05 fc 11 11 80 00 	movl   $0xfec00000,0x801111fc
80102a50:	00 c0 fe 
  maxintr = (ioapicread(REG_VER) >> 16) & 0xFF;
80102a53:	6a 01                	push   $0x1
80102a55:	e8 aa ff ff ff       	call   80102a04 <ioapicread>
80102a5a:	83 c4 04             	add    $0x4,%esp
80102a5d:	c1 e8 10             	shr    $0x10,%eax
80102a60:	25 ff 00 00 00       	and    $0xff,%eax
80102a65:	89 45 f0             	mov    %eax,-0x10(%ebp)
  id = ioapicread(REG_ID) >> 24;
80102a68:	6a 00                	push   $0x0
80102a6a:	e8 95 ff ff ff       	call   80102a04 <ioapicread>
80102a6f:	83 c4 04             	add    $0x4,%esp
80102a72:	c1 e8 18             	shr    $0x18,%eax
80102a75:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if(id != ioapicid)
80102a78:	0f b6 05 48 19 11 80 	movzbl 0x80111948,%eax
80102a7f:	0f b6 c0             	movzbl %al,%eax
80102a82:	39 45 ec             	cmp    %eax,-0x14(%ebp)
80102a85:	74 10                	je     80102a97 <ioapicinit+0x61>
    cprintf("ioapicinit: id isn't equal to ioapicid; not a MP\n");
80102a87:	83 ec 0c             	sub    $0xc,%esp
80102a8a:	68 10 8a 10 80       	push   $0x80108a10
80102a8f:	e8 30 d9 ff ff       	call   801003c4 <cprintf>
80102a94:	83 c4 10             	add    $0x10,%esp

  // Mark all interrupts edge-triggered, active high, disabled,
  // and not routed to any CPUs.
  for(i = 0; i <= maxintr; i++){
80102a97:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102a9e:	eb 3f                	jmp    80102adf <ioapicinit+0xa9>
    ioapicwrite(REG_TABLE+2*i, INT_DISABLED | (T_IRQ0 + i));
80102aa0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102aa3:	83 c0 20             	add    $0x20,%eax
80102aa6:	0d 00 00 01 00       	or     $0x10000,%eax
80102aab:	89 c2                	mov    %eax,%edx
80102aad:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102ab0:	83 c0 08             	add    $0x8,%eax
80102ab3:	01 c0                	add    %eax,%eax
80102ab5:	83 ec 08             	sub    $0x8,%esp
80102ab8:	52                   	push   %edx
80102ab9:	50                   	push   %eax
80102aba:	e8 5c ff ff ff       	call   80102a1b <ioapicwrite>
80102abf:	83 c4 10             	add    $0x10,%esp
    ioapicwrite(REG_TABLE+2*i+1, 0);
80102ac2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102ac5:	83 c0 08             	add    $0x8,%eax
80102ac8:	01 c0                	add    %eax,%eax
80102aca:	83 c0 01             	add    $0x1,%eax
80102acd:	83 ec 08             	sub    $0x8,%esp
80102ad0:	6a 00                	push   $0x0
80102ad2:	50                   	push   %eax
80102ad3:	e8 43 ff ff ff       	call   80102a1b <ioapicwrite>
80102ad8:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i <= maxintr; i++){
80102adb:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80102adf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102ae2:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80102ae5:	7e b9                	jle    80102aa0 <ioapicinit+0x6a>
80102ae7:	eb 01                	jmp    80102aea <ioapicinit+0xb4>
    return;
80102ae9:	90                   	nop
  }
}
80102aea:	c9                   	leave
80102aeb:	c3                   	ret

80102aec <ioapicenable>:

void
ioapicenable(int irq, int cpunum)
{
80102aec:	55                   	push   %ebp
80102aed:	89 e5                	mov    %esp,%ebp
  if(!ismp)
80102aef:	a1 40 19 11 80       	mov    0x80111940,%eax
80102af4:	85 c0                	test   %eax,%eax
80102af6:	74 39                	je     80102b31 <ioapicenable+0x45>
    return;

  // Mark interrupt edge-triggered, active high,
  // enabled, and routed to the given cpunum,
  // which happens to be that cpu's APIC ID.
  ioapicwrite(REG_TABLE+2*irq, T_IRQ0 + irq);
80102af8:	8b 45 08             	mov    0x8(%ebp),%eax
80102afb:	83 c0 20             	add    $0x20,%eax
80102afe:	89 c2                	mov    %eax,%edx
80102b00:	8b 45 08             	mov    0x8(%ebp),%eax
80102b03:	83 c0 08             	add    $0x8,%eax
80102b06:	01 c0                	add    %eax,%eax
80102b08:	52                   	push   %edx
80102b09:	50                   	push   %eax
80102b0a:	e8 0c ff ff ff       	call   80102a1b <ioapicwrite>
80102b0f:	83 c4 08             	add    $0x8,%esp
  ioapicwrite(REG_TABLE+2*irq+1, cpunum << 24);
80102b12:	8b 45 0c             	mov    0xc(%ebp),%eax
80102b15:	c1 e0 18             	shl    $0x18,%eax
80102b18:	89 c2                	mov    %eax,%edx
80102b1a:	8b 45 08             	mov    0x8(%ebp),%eax
80102b1d:	83 c0 08             	add    $0x8,%eax
80102b20:	01 c0                	add    %eax,%eax
80102b22:	83 c0 01             	add    $0x1,%eax
80102b25:	52                   	push   %edx
80102b26:	50                   	push   %eax
80102b27:	e8 ef fe ff ff       	call   80102a1b <ioapicwrite>
80102b2c:	83 c4 08             	add    $0x8,%esp
80102b2f:	eb 01                	jmp    80102b32 <ioapicenable+0x46>
    return;
80102b31:	90                   	nop
}
80102b32:	c9                   	leave
80102b33:	c3                   	ret

80102b34 <v2p>:
#define KERNBASE 0x80000000         // First kernel virtual address
#define KERNLINK (KERNBASE+EXTMEM)  // Address where kernel is linked

#ifndef __ASSEMBLER__

static inline uint v2p(void *a) { return ((uint) (a))  - KERNBASE; }
80102b34:	55                   	push   %ebp
80102b35:	89 e5                	mov    %esp,%ebp
80102b37:	8b 45 08             	mov    0x8(%ebp),%eax
80102b3a:	05 00 00 00 80       	add    $0x80000000,%eax
80102b3f:	5d                   	pop    %ebp
80102b40:	c3                   	ret

80102b41 <kinit1>:
// the pages mapped by entrypgdir on free list.
// 2. main() calls kinit2() with the rest of the physical pages
// after installing a full page table that maps them on all cores.
void
kinit1(void *vstart, void *vend)
{
80102b41:	55                   	push   %ebp
80102b42:	89 e5                	mov    %esp,%ebp
80102b44:	83 ec 08             	sub    $0x8,%esp
  initlock(&kmem.lock, "kmem");
80102b47:	83 ec 08             	sub    $0x8,%esp
80102b4a:	68 42 8a 10 80       	push   $0x80108a42
80102b4f:	68 20 12 11 80       	push   $0x80111220
80102b54:	e8 04 25 00 00       	call   8010505d <initlock>
80102b59:	83 c4 10             	add    $0x10,%esp
  kmem.use_lock = 0;
80102b5c:	c7 05 54 12 11 80 00 	movl   $0x0,0x80111254
80102b63:	00 00 00 
  freerange(vstart, vend);
80102b66:	83 ec 08             	sub    $0x8,%esp
80102b69:	ff 75 0c             	push   0xc(%ebp)
80102b6c:	ff 75 08             	push   0x8(%ebp)
80102b6f:	e8 2a 00 00 00       	call   80102b9e <freerange>
80102b74:	83 c4 10             	add    $0x10,%esp
}
80102b77:	90                   	nop
80102b78:	c9                   	leave
80102b79:	c3                   	ret

80102b7a <kinit2>:

void
kinit2(void *vstart, void *vend)
{
80102b7a:	55                   	push   %ebp
80102b7b:	89 e5                	mov    %esp,%ebp
80102b7d:	83 ec 08             	sub    $0x8,%esp
  freerange(vstart, vend);
80102b80:	83 ec 08             	sub    $0x8,%esp
80102b83:	ff 75 0c             	push   0xc(%ebp)
80102b86:	ff 75 08             	push   0x8(%ebp)
80102b89:	e8 10 00 00 00       	call   80102b9e <freerange>
80102b8e:	83 c4 10             	add    $0x10,%esp
  kmem.use_lock = 1;
80102b91:	c7 05 54 12 11 80 01 	movl   $0x1,0x80111254
80102b98:	00 00 00 
}
80102b9b:	90                   	nop
80102b9c:	c9                   	leave
80102b9d:	c3                   	ret

80102b9e <freerange>:

void
freerange(void *vstart, void *vend)
{
80102b9e:	55                   	push   %ebp
80102b9f:	89 e5                	mov    %esp,%ebp
80102ba1:	83 ec 18             	sub    $0x18,%esp
  char *p;
  p = (char*)PGROUNDUP((uint)vstart);
80102ba4:	8b 45 08             	mov    0x8(%ebp),%eax
80102ba7:	05 ff 0f 00 00       	add    $0xfff,%eax
80102bac:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80102bb1:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
80102bb4:	eb 15                	jmp    80102bcb <freerange+0x2d>
    kfree(p);
80102bb6:	83 ec 0c             	sub    $0xc,%esp
80102bb9:	ff 75 f4             	push   -0xc(%ebp)
80102bbc:	e8 1b 00 00 00       	call   80102bdc <kfree>
80102bc1:	83 c4 10             	add    $0x10,%esp
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
80102bc4:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80102bcb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102bce:	05 00 10 00 00       	add    $0x1000,%eax
80102bd3:	39 45 0c             	cmp    %eax,0xc(%ebp)
80102bd6:	73 de                	jae    80102bb6 <freerange+0x18>
}
80102bd8:	90                   	nop
80102bd9:	90                   	nop
80102bda:	c9                   	leave
80102bdb:	c3                   	ret

80102bdc <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(char *v)
{
80102bdc:	55                   	push   %ebp
80102bdd:	89 e5                	mov    %esp,%ebp
80102bdf:	83 ec 18             	sub    $0x18,%esp
  struct run *r;

  if((uint)v % PGSIZE || v < end || v2p(v) >= PHYSTOP)
80102be2:	8b 45 08             	mov    0x8(%ebp),%eax
80102be5:	25 ff 0f 00 00       	and    $0xfff,%eax
80102bea:	85 c0                	test   %eax,%eax
80102bec:	75 1b                	jne    80102c09 <kfree+0x2d>
80102bee:	81 7d 08 60 51 11 80 	cmpl   $0x80115160,0x8(%ebp)
80102bf5:	72 12                	jb     80102c09 <kfree+0x2d>
80102bf7:	ff 75 08             	push   0x8(%ebp)
80102bfa:	e8 35 ff ff ff       	call   80102b34 <v2p>
80102bff:	83 c4 04             	add    $0x4,%esp
80102c02:	3d ff ff ff 0d       	cmp    $0xdffffff,%eax
80102c07:	76 0d                	jbe    80102c16 <kfree+0x3a>
    panic("kfree");
80102c09:	83 ec 0c             	sub    $0xc,%esp
80102c0c:	68 47 8a 10 80       	push   $0x80108a47
80102c11:	e8 63 d9 ff ff       	call   80100579 <panic>

  // Fill with junk to catch dangling refs.
  memset(v, 1, PGSIZE);
80102c16:	83 ec 04             	sub    $0x4,%esp
80102c19:	68 00 10 00 00       	push   $0x1000
80102c1e:	6a 01                	push   $0x1
80102c20:	ff 75 08             	push   0x8(%ebp)
80102c23:	e8 bb 26 00 00       	call   801052e3 <memset>
80102c28:	83 c4 10             	add    $0x10,%esp

  if(kmem.use_lock)
80102c2b:	a1 54 12 11 80       	mov    0x80111254,%eax
80102c30:	85 c0                	test   %eax,%eax
80102c32:	74 10                	je     80102c44 <kfree+0x68>
    acquire(&kmem.lock);
80102c34:	83 ec 0c             	sub    $0xc,%esp
80102c37:	68 20 12 11 80       	push   $0x80111220
80102c3c:	e8 3e 24 00 00       	call   8010507f <acquire>
80102c41:	83 c4 10             	add    $0x10,%esp
  r = (struct run*)v;
80102c44:	8b 45 08             	mov    0x8(%ebp),%eax
80102c47:	89 45 f4             	mov    %eax,-0xc(%ebp)
  r->next = kmem.freelist;
80102c4a:	8b 15 58 12 11 80    	mov    0x80111258,%edx
80102c50:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102c53:	89 10                	mov    %edx,(%eax)
  kmem.freelist = r;
80102c55:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102c58:	a3 58 12 11 80       	mov    %eax,0x80111258
  free_frame_cnt++;         // CS 3320: project 2
80102c5d:	a1 00 12 11 80       	mov    0x80111200,%eax
80102c62:	83 c0 01             	add    $0x1,%eax
80102c65:	a3 00 12 11 80       	mov    %eax,0x80111200
  if(kmem.use_lock)
80102c6a:	a1 54 12 11 80       	mov    0x80111254,%eax
80102c6f:	85 c0                	test   %eax,%eax
80102c71:	74 10                	je     80102c83 <kfree+0xa7>
    release(&kmem.lock);
80102c73:	83 ec 0c             	sub    $0xc,%esp
80102c76:	68 20 12 11 80       	push   $0x80111220
80102c7b:	e8 66 24 00 00       	call   801050e6 <release>
80102c80:	83 c4 10             	add    $0x10,%esp
}
80102c83:	90                   	nop
80102c84:	c9                   	leave
80102c85:	c3                   	ret

80102c86 <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
char*
kalloc(void)
{
80102c86:	55                   	push   %ebp
80102c87:	89 e5                	mov    %esp,%ebp
80102c89:	83 ec 18             	sub    $0x18,%esp
  struct run *r;

  if(kmem.use_lock)
80102c8c:	a1 54 12 11 80       	mov    0x80111254,%eax
80102c91:	85 c0                	test   %eax,%eax
80102c93:	74 10                	je     80102ca5 <kalloc+0x1f>
    acquire(&kmem.lock);
80102c95:	83 ec 0c             	sub    $0xc,%esp
80102c98:	68 20 12 11 80       	push   $0x80111220
80102c9d:	e8 dd 23 00 00       	call   8010507f <acquire>
80102ca2:	83 c4 10             	add    $0x10,%esp
  r = kmem.freelist;
80102ca5:	a1 58 12 11 80       	mov    0x80111258,%eax
80102caa:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(r)
80102cad:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80102cb1:	74 17                	je     80102cca <kalloc+0x44>
  {
    free_frame_cnt--;     // CS 3320: project 2
80102cb3:	a1 00 12 11 80       	mov    0x80111200,%eax
80102cb8:	83 e8 01             	sub    $0x1,%eax
80102cbb:	a3 00 12 11 80       	mov    %eax,0x80111200
    kmem.freelist = r->next;
80102cc0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102cc3:	8b 00                	mov    (%eax),%eax
80102cc5:	a3 58 12 11 80       	mov    %eax,0x80111258
  }
  if(kmem.use_lock)
80102cca:	a1 54 12 11 80       	mov    0x80111254,%eax
80102ccf:	85 c0                	test   %eax,%eax
80102cd1:	74 10                	je     80102ce3 <kalloc+0x5d>
    release(&kmem.lock);
80102cd3:	83 ec 0c             	sub    $0xc,%esp
80102cd6:	68 20 12 11 80       	push   $0x80111220
80102cdb:	e8 06 24 00 00       	call   801050e6 <release>
80102ce0:	83 c4 10             	add    $0x10,%esp
  return (char*)r;
80102ce3:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80102ce6:	c9                   	leave
80102ce7:	c3                   	ret

80102ce8 <inb>:
{
80102ce8:	55                   	push   %ebp
80102ce9:	89 e5                	mov    %esp,%ebp
80102ceb:	83 ec 14             	sub    $0x14,%esp
80102cee:	8b 45 08             	mov    0x8(%ebp),%eax
80102cf1:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102cf5:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80102cf9:	89 c2                	mov    %eax,%edx
80102cfb:	ec                   	in     (%dx),%al
80102cfc:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80102cff:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80102d03:	c9                   	leave
80102d04:	c3                   	ret

80102d05 <kbdgetc>:
#include "defs.h"
#include "kbd.h"

int
kbdgetc(void)
{
80102d05:	55                   	push   %ebp
80102d06:	89 e5                	mov    %esp,%ebp
80102d08:	83 ec 10             	sub    $0x10,%esp
  static uchar *charcode[4] = {
    normalmap, shiftmap, ctlmap, ctlmap
  };
  uint st, data, c;

  st = inb(KBSTATP);
80102d0b:	6a 64                	push   $0x64
80102d0d:	e8 d6 ff ff ff       	call   80102ce8 <inb>
80102d12:	83 c4 04             	add    $0x4,%esp
80102d15:	0f b6 c0             	movzbl %al,%eax
80102d18:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if((st & KBS_DIB) == 0)
80102d1b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102d1e:	83 e0 01             	and    $0x1,%eax
80102d21:	85 c0                	test   %eax,%eax
80102d23:	75 0a                	jne    80102d2f <kbdgetc+0x2a>
    return -1;
80102d25:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102d2a:	e9 23 01 00 00       	jmp    80102e52 <kbdgetc+0x14d>
  data = inb(KBDATAP);
80102d2f:	6a 60                	push   $0x60
80102d31:	e8 b2 ff ff ff       	call   80102ce8 <inb>
80102d36:	83 c4 04             	add    $0x4,%esp
80102d39:	0f b6 c0             	movzbl %al,%eax
80102d3c:	89 45 fc             	mov    %eax,-0x4(%ebp)

  if(data == 0xE0){
80102d3f:	81 7d fc e0 00 00 00 	cmpl   $0xe0,-0x4(%ebp)
80102d46:	75 17                	jne    80102d5f <kbdgetc+0x5a>
    shift |= E0ESC;
80102d48:	a1 5c 12 11 80       	mov    0x8011125c,%eax
80102d4d:	83 c8 40             	or     $0x40,%eax
80102d50:	a3 5c 12 11 80       	mov    %eax,0x8011125c
    return 0;
80102d55:	b8 00 00 00 00       	mov    $0x0,%eax
80102d5a:	e9 f3 00 00 00       	jmp    80102e52 <kbdgetc+0x14d>
  } else if(data & 0x80){
80102d5f:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102d62:	25 80 00 00 00       	and    $0x80,%eax
80102d67:	85 c0                	test   %eax,%eax
80102d69:	74 45                	je     80102db0 <kbdgetc+0xab>
    // Key released
    data = (shift & E0ESC ? data : data & 0x7F);
80102d6b:	a1 5c 12 11 80       	mov    0x8011125c,%eax
80102d70:	83 e0 40             	and    $0x40,%eax
80102d73:	85 c0                	test   %eax,%eax
80102d75:	75 08                	jne    80102d7f <kbdgetc+0x7a>
80102d77:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102d7a:	83 e0 7f             	and    $0x7f,%eax
80102d7d:	eb 03                	jmp    80102d82 <kbdgetc+0x7d>
80102d7f:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102d82:	89 45 fc             	mov    %eax,-0x4(%ebp)
    shift &= ~(shiftcode[data] | E0ESC);
80102d85:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102d88:	05 20 90 10 80       	add    $0x80109020,%eax
80102d8d:	0f b6 00             	movzbl (%eax),%eax
80102d90:	83 c8 40             	or     $0x40,%eax
80102d93:	0f b6 c0             	movzbl %al,%eax
80102d96:	f7 d0                	not    %eax
80102d98:	89 c2                	mov    %eax,%edx
80102d9a:	a1 5c 12 11 80       	mov    0x8011125c,%eax
80102d9f:	21 d0                	and    %edx,%eax
80102da1:	a3 5c 12 11 80       	mov    %eax,0x8011125c
    return 0;
80102da6:	b8 00 00 00 00       	mov    $0x0,%eax
80102dab:	e9 a2 00 00 00       	jmp    80102e52 <kbdgetc+0x14d>
  } else if(shift & E0ESC){
80102db0:	a1 5c 12 11 80       	mov    0x8011125c,%eax
80102db5:	83 e0 40             	and    $0x40,%eax
80102db8:	85 c0                	test   %eax,%eax
80102dba:	74 14                	je     80102dd0 <kbdgetc+0xcb>
    // Last character was an E0 escape; or with 0x80
    data |= 0x80;
80102dbc:	81 4d fc 80 00 00 00 	orl    $0x80,-0x4(%ebp)
    shift &= ~E0ESC;
80102dc3:	a1 5c 12 11 80       	mov    0x8011125c,%eax
80102dc8:	83 e0 bf             	and    $0xffffffbf,%eax
80102dcb:	a3 5c 12 11 80       	mov    %eax,0x8011125c
  }

  shift |= shiftcode[data];
80102dd0:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102dd3:	05 20 90 10 80       	add    $0x80109020,%eax
80102dd8:	0f b6 00             	movzbl (%eax),%eax
80102ddb:	0f b6 d0             	movzbl %al,%edx
80102dde:	a1 5c 12 11 80       	mov    0x8011125c,%eax
80102de3:	09 d0                	or     %edx,%eax
80102de5:	a3 5c 12 11 80       	mov    %eax,0x8011125c
  shift ^= togglecode[data];
80102dea:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102ded:	05 20 91 10 80       	add    $0x80109120,%eax
80102df2:	0f b6 00             	movzbl (%eax),%eax
80102df5:	0f b6 d0             	movzbl %al,%edx
80102df8:	a1 5c 12 11 80       	mov    0x8011125c,%eax
80102dfd:	31 d0                	xor    %edx,%eax
80102dff:	a3 5c 12 11 80       	mov    %eax,0x8011125c
  c = charcode[shift & (CTL | SHIFT)][data];
80102e04:	a1 5c 12 11 80       	mov    0x8011125c,%eax
80102e09:	83 e0 03             	and    $0x3,%eax
80102e0c:	8b 14 85 20 95 10 80 	mov    -0x7fef6ae0(,%eax,4),%edx
80102e13:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102e16:	01 d0                	add    %edx,%eax
80102e18:	0f b6 00             	movzbl (%eax),%eax
80102e1b:	0f b6 c0             	movzbl %al,%eax
80102e1e:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if(shift & CAPSLOCK){
80102e21:	a1 5c 12 11 80       	mov    0x8011125c,%eax
80102e26:	83 e0 08             	and    $0x8,%eax
80102e29:	85 c0                	test   %eax,%eax
80102e2b:	74 22                	je     80102e4f <kbdgetc+0x14a>
    if('a' <= c && c <= 'z')
80102e2d:	83 7d f8 60          	cmpl   $0x60,-0x8(%ebp)
80102e31:	76 0c                	jbe    80102e3f <kbdgetc+0x13a>
80102e33:	83 7d f8 7a          	cmpl   $0x7a,-0x8(%ebp)
80102e37:	77 06                	ja     80102e3f <kbdgetc+0x13a>
      c += 'A' - 'a';
80102e39:	83 6d f8 20          	subl   $0x20,-0x8(%ebp)
80102e3d:	eb 10                	jmp    80102e4f <kbdgetc+0x14a>
    else if('A' <= c && c <= 'Z')
80102e3f:	83 7d f8 40          	cmpl   $0x40,-0x8(%ebp)
80102e43:	76 0a                	jbe    80102e4f <kbdgetc+0x14a>
80102e45:	83 7d f8 5a          	cmpl   $0x5a,-0x8(%ebp)
80102e49:	77 04                	ja     80102e4f <kbdgetc+0x14a>
      c += 'a' - 'A';
80102e4b:	83 45 f8 20          	addl   $0x20,-0x8(%ebp)
  }
  return c;
80102e4f:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
80102e52:	c9                   	leave
80102e53:	c3                   	ret

80102e54 <kbdintr>:

void
kbdintr(void)
{
80102e54:	55                   	push   %ebp
80102e55:	89 e5                	mov    %esp,%ebp
80102e57:	83 ec 08             	sub    $0x8,%esp
  consoleintr(kbdgetc);
80102e5a:	83 ec 0c             	sub    $0xc,%esp
80102e5d:	68 05 2d 10 80       	push   $0x80102d05
80102e62:	e8 af d9 ff ff       	call   80100816 <consoleintr>
80102e67:	83 c4 10             	add    $0x10,%esp
}
80102e6a:	90                   	nop
80102e6b:	c9                   	leave
80102e6c:	c3                   	ret

80102e6d <inb>:
{
80102e6d:	55                   	push   %ebp
80102e6e:	89 e5                	mov    %esp,%ebp
80102e70:	83 ec 14             	sub    $0x14,%esp
80102e73:	8b 45 08             	mov    0x8(%ebp),%eax
80102e76:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102e7a:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80102e7e:	89 c2                	mov    %eax,%edx
80102e80:	ec                   	in     (%dx),%al
80102e81:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80102e84:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80102e88:	c9                   	leave
80102e89:	c3                   	ret

80102e8a <outb>:
{
80102e8a:	55                   	push   %ebp
80102e8b:	89 e5                	mov    %esp,%ebp
80102e8d:	83 ec 08             	sub    $0x8,%esp
80102e90:	8b 55 08             	mov    0x8(%ebp),%edx
80102e93:	8b 45 0c             	mov    0xc(%ebp),%eax
80102e96:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80102e9a:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102e9d:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80102ea1:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80102ea5:	ee                   	out    %al,(%dx)
}
80102ea6:	90                   	nop
80102ea7:	c9                   	leave
80102ea8:	c3                   	ret

80102ea9 <readeflags>:
{
80102ea9:	55                   	push   %ebp
80102eaa:	89 e5                	mov    %esp,%ebp
80102eac:	83 ec 10             	sub    $0x10,%esp
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80102eaf:	9c                   	pushf
80102eb0:	58                   	pop    %eax
80102eb1:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return eflags;
80102eb4:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80102eb7:	c9                   	leave
80102eb8:	c3                   	ret

80102eb9 <lapicw>:

volatile uint *lapic;  // Initialized in mp.c

static void
lapicw(int index, int value)
{
80102eb9:	55                   	push   %ebp
80102eba:	89 e5                	mov    %esp,%ebp
  lapic[index] = value;
80102ebc:	a1 60 12 11 80       	mov    0x80111260,%eax
80102ec1:	8b 55 08             	mov    0x8(%ebp),%edx
80102ec4:	c1 e2 02             	shl    $0x2,%edx
80102ec7:	01 c2                	add    %eax,%edx
80102ec9:	8b 45 0c             	mov    0xc(%ebp),%eax
80102ecc:	89 02                	mov    %eax,(%edx)
  lapic[ID];  // wait for write to finish, by reading
80102ece:	a1 60 12 11 80       	mov    0x80111260,%eax
80102ed3:	83 c0 20             	add    $0x20,%eax
80102ed6:	8b 00                	mov    (%eax),%eax
}
80102ed8:	90                   	nop
80102ed9:	5d                   	pop    %ebp
80102eda:	c3                   	ret

80102edb <lapicinit>:
//PAGEBREAK!

void
lapicinit(void)
{
80102edb:	55                   	push   %ebp
80102edc:	89 e5                	mov    %esp,%ebp
  if(!lapic) 
80102ede:	a1 60 12 11 80       	mov    0x80111260,%eax
80102ee3:	85 c0                	test   %eax,%eax
80102ee5:	0f 84 09 01 00 00    	je     80102ff4 <lapicinit+0x119>
    return;

  // Enable local APIC; set spurious interrupt vector.
  lapicw(SVR, ENABLE | (T_IRQ0 + IRQ_SPURIOUS));
80102eeb:	68 3f 01 00 00       	push   $0x13f
80102ef0:	6a 3c                	push   $0x3c
80102ef2:	e8 c2 ff ff ff       	call   80102eb9 <lapicw>
80102ef7:	83 c4 08             	add    $0x8,%esp

  // The timer repeatedly counts down at bus frequency
  // from lapic[TICR] and then issues an interrupt.  
  // If xv6 cared more about precise timekeeping,
  // TICR would be calibrated using an external time source.
  lapicw(TDCR, X1);
80102efa:	6a 0b                	push   $0xb
80102efc:	68 f8 00 00 00       	push   $0xf8
80102f01:	e8 b3 ff ff ff       	call   80102eb9 <lapicw>
80102f06:	83 c4 08             	add    $0x8,%esp
  lapicw(TIMER, PERIODIC | (T_IRQ0 + IRQ_TIMER));
80102f09:	68 20 00 02 00       	push   $0x20020
80102f0e:	68 c8 00 00 00       	push   $0xc8
80102f13:	e8 a1 ff ff ff       	call   80102eb9 <lapicw>
80102f18:	83 c4 08             	add    $0x8,%esp
  lapicw(TICR, 10000000); 
80102f1b:	68 80 96 98 00       	push   $0x989680
80102f20:	68 e0 00 00 00       	push   $0xe0
80102f25:	e8 8f ff ff ff       	call   80102eb9 <lapicw>
80102f2a:	83 c4 08             	add    $0x8,%esp

  // Disable logical interrupt lines.
  lapicw(LINT0, MASKED);
80102f2d:	68 00 00 01 00       	push   $0x10000
80102f32:	68 d4 00 00 00       	push   $0xd4
80102f37:	e8 7d ff ff ff       	call   80102eb9 <lapicw>
80102f3c:	83 c4 08             	add    $0x8,%esp
  lapicw(LINT1, MASKED);
80102f3f:	68 00 00 01 00       	push   $0x10000
80102f44:	68 d8 00 00 00       	push   $0xd8
80102f49:	e8 6b ff ff ff       	call   80102eb9 <lapicw>
80102f4e:	83 c4 08             	add    $0x8,%esp

  // Disable performance counter overflow interrupts
  // on machines that provide that interrupt entry.
  if(((lapic[VER]>>16) & 0xFF) >= 4)
80102f51:	a1 60 12 11 80       	mov    0x80111260,%eax
80102f56:	83 c0 30             	add    $0x30,%eax
80102f59:	8b 00                	mov    (%eax),%eax
80102f5b:	25 00 00 fc 00       	and    $0xfc0000,%eax
80102f60:	85 c0                	test   %eax,%eax
80102f62:	74 12                	je     80102f76 <lapicinit+0x9b>
    lapicw(PCINT, MASKED);
80102f64:	68 00 00 01 00       	push   $0x10000
80102f69:	68 d0 00 00 00       	push   $0xd0
80102f6e:	e8 46 ff ff ff       	call   80102eb9 <lapicw>
80102f73:	83 c4 08             	add    $0x8,%esp

  // Map error interrupt to IRQ_ERROR.
  lapicw(ERROR, T_IRQ0 + IRQ_ERROR);
80102f76:	6a 33                	push   $0x33
80102f78:	68 dc 00 00 00       	push   $0xdc
80102f7d:	e8 37 ff ff ff       	call   80102eb9 <lapicw>
80102f82:	83 c4 08             	add    $0x8,%esp

  // Clear error status register (requires back-to-back writes).
  lapicw(ESR, 0);
80102f85:	6a 00                	push   $0x0
80102f87:	68 a0 00 00 00       	push   $0xa0
80102f8c:	e8 28 ff ff ff       	call   80102eb9 <lapicw>
80102f91:	83 c4 08             	add    $0x8,%esp
  lapicw(ESR, 0);
80102f94:	6a 00                	push   $0x0
80102f96:	68 a0 00 00 00       	push   $0xa0
80102f9b:	e8 19 ff ff ff       	call   80102eb9 <lapicw>
80102fa0:	83 c4 08             	add    $0x8,%esp

  // Ack any outstanding interrupts.
  lapicw(EOI, 0);
80102fa3:	6a 00                	push   $0x0
80102fa5:	6a 2c                	push   $0x2c
80102fa7:	e8 0d ff ff ff       	call   80102eb9 <lapicw>
80102fac:	83 c4 08             	add    $0x8,%esp

  // Send an Init Level De-Assert to synchronise arbitration ID's.
  lapicw(ICRHI, 0);
80102faf:	6a 00                	push   $0x0
80102fb1:	68 c4 00 00 00       	push   $0xc4
80102fb6:	e8 fe fe ff ff       	call   80102eb9 <lapicw>
80102fbb:	83 c4 08             	add    $0x8,%esp
  lapicw(ICRLO, BCAST | INIT | LEVEL);
80102fbe:	68 00 85 08 00       	push   $0x88500
80102fc3:	68 c0 00 00 00       	push   $0xc0
80102fc8:	e8 ec fe ff ff       	call   80102eb9 <lapicw>
80102fcd:	83 c4 08             	add    $0x8,%esp
  while(lapic[ICRLO] & DELIVS)
80102fd0:	90                   	nop
80102fd1:	a1 60 12 11 80       	mov    0x80111260,%eax
80102fd6:	05 00 03 00 00       	add    $0x300,%eax
80102fdb:	8b 00                	mov    (%eax),%eax
80102fdd:	25 00 10 00 00       	and    $0x1000,%eax
80102fe2:	85 c0                	test   %eax,%eax
80102fe4:	75 eb                	jne    80102fd1 <lapicinit+0xf6>
    ;

  // Enable interrupts on the APIC (but not on the processor).
  lapicw(TPR, 0);
80102fe6:	6a 00                	push   $0x0
80102fe8:	6a 20                	push   $0x20
80102fea:	e8 ca fe ff ff       	call   80102eb9 <lapicw>
80102fef:	83 c4 08             	add    $0x8,%esp
80102ff2:	eb 01                	jmp    80102ff5 <lapicinit+0x11a>
    return;
80102ff4:	90                   	nop
}
80102ff5:	c9                   	leave
80102ff6:	c3                   	ret

80102ff7 <cpunum>:

int
cpunum(void)
{
80102ff7:	55                   	push   %ebp
80102ff8:	89 e5                	mov    %esp,%ebp
80102ffa:	83 ec 08             	sub    $0x8,%esp
  // Cannot call cpu when interrupts are enabled:
  // result not guaranteed to last long enough to be used!
  // Would prefer to panic but even printing is chancy here:
  // almost everything, including cprintf and panic, calls cpu,
  // often indirectly through acquire and release.
  if(readeflags()&FL_IF){
80102ffd:	e8 a7 fe ff ff       	call   80102ea9 <readeflags>
80103002:	25 00 02 00 00       	and    $0x200,%eax
80103007:	85 c0                	test   %eax,%eax
80103009:	74 26                	je     80103031 <cpunum+0x3a>
    static int n;
    if(n++ == 0)
8010300b:	a1 64 12 11 80       	mov    0x80111264,%eax
80103010:	8d 50 01             	lea    0x1(%eax),%edx
80103013:	89 15 64 12 11 80    	mov    %edx,0x80111264
80103019:	85 c0                	test   %eax,%eax
8010301b:	75 14                	jne    80103031 <cpunum+0x3a>
      cprintf("cpu called from %x with interrupts enabled\n",
8010301d:	8b 45 04             	mov    0x4(%ebp),%eax
80103020:	83 ec 08             	sub    $0x8,%esp
80103023:	50                   	push   %eax
80103024:	68 50 8a 10 80       	push   $0x80108a50
80103029:	e8 96 d3 ff ff       	call   801003c4 <cprintf>
8010302e:	83 c4 10             	add    $0x10,%esp
        __builtin_return_address(0));
  }

  if(lapic)
80103031:	a1 60 12 11 80       	mov    0x80111260,%eax
80103036:	85 c0                	test   %eax,%eax
80103038:	74 0f                	je     80103049 <cpunum+0x52>
    return lapic[ID]>>24;
8010303a:	a1 60 12 11 80       	mov    0x80111260,%eax
8010303f:	83 c0 20             	add    $0x20,%eax
80103042:	8b 00                	mov    (%eax),%eax
80103044:	c1 e8 18             	shr    $0x18,%eax
80103047:	eb 05                	jmp    8010304e <cpunum+0x57>
  return 0;
80103049:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010304e:	c9                   	leave
8010304f:	c3                   	ret

80103050 <lapiceoi>:

// Acknowledge interrupt.
void
lapiceoi(void)
{
80103050:	55                   	push   %ebp
80103051:	89 e5                	mov    %esp,%ebp
  if(lapic)
80103053:	a1 60 12 11 80       	mov    0x80111260,%eax
80103058:	85 c0                	test   %eax,%eax
8010305a:	74 0c                	je     80103068 <lapiceoi+0x18>
    lapicw(EOI, 0);
8010305c:	6a 00                	push   $0x0
8010305e:	6a 2c                	push   $0x2c
80103060:	e8 54 fe ff ff       	call   80102eb9 <lapicw>
80103065:	83 c4 08             	add    $0x8,%esp
}
80103068:	90                   	nop
80103069:	c9                   	leave
8010306a:	c3                   	ret

8010306b <microdelay>:

// Spin for a given number of microseconds.
// On real hardware would want to tune this dynamically.
void
microdelay(int us)
{
8010306b:	55                   	push   %ebp
8010306c:	89 e5                	mov    %esp,%ebp
}
8010306e:	90                   	nop
8010306f:	5d                   	pop    %ebp
80103070:	c3                   	ret

80103071 <lapicstartap>:

// Start additional processor running entry code at addr.
// See Appendix B of MultiProcessor Specification.
void
lapicstartap(uchar apicid, uint addr)
{
80103071:	55                   	push   %ebp
80103072:	89 e5                	mov    %esp,%ebp
80103074:	83 ec 14             	sub    $0x14,%esp
80103077:	8b 45 08             	mov    0x8(%ebp),%eax
8010307a:	88 45 ec             	mov    %al,-0x14(%ebp)
  ushort *wrv;
  
  // "The BSP must initialize CMOS shutdown code to 0AH
  // and the warm reset vector (DWORD based at 40:67) to point at
  // the AP startup code prior to the [universal startup algorithm]."
  outb(CMOS_PORT, 0xF);  // offset 0xF is shutdown code
8010307d:	6a 0f                	push   $0xf
8010307f:	6a 70                	push   $0x70
80103081:	e8 04 fe ff ff       	call   80102e8a <outb>
80103086:	83 c4 08             	add    $0x8,%esp
  outb(CMOS_PORT+1, 0x0A);
80103089:	6a 0a                	push   $0xa
8010308b:	6a 71                	push   $0x71
8010308d:	e8 f8 fd ff ff       	call   80102e8a <outb>
80103092:	83 c4 08             	add    $0x8,%esp
  wrv = (ushort*)P2V((0x40<<4 | 0x67));  // Warm reset vector
80103095:	c7 45 f8 67 04 00 80 	movl   $0x80000467,-0x8(%ebp)
  wrv[0] = 0;
8010309c:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010309f:	66 c7 00 00 00       	movw   $0x0,(%eax)
  wrv[1] = addr >> 4;
801030a4:	8b 45 0c             	mov    0xc(%ebp),%eax
801030a7:	c1 e8 04             	shr    $0x4,%eax
801030aa:	89 c2                	mov    %eax,%edx
801030ac:	8b 45 f8             	mov    -0x8(%ebp),%eax
801030af:	83 c0 02             	add    $0x2,%eax
801030b2:	66 89 10             	mov    %dx,(%eax)

  // "Universal startup algorithm."
  // Send INIT (level-triggered) interrupt to reset other CPU.
  lapicw(ICRHI, apicid<<24);
801030b5:	0f b6 45 ec          	movzbl -0x14(%ebp),%eax
801030b9:	c1 e0 18             	shl    $0x18,%eax
801030bc:	50                   	push   %eax
801030bd:	68 c4 00 00 00       	push   $0xc4
801030c2:	e8 f2 fd ff ff       	call   80102eb9 <lapicw>
801030c7:	83 c4 08             	add    $0x8,%esp
  lapicw(ICRLO, INIT | LEVEL | ASSERT);
801030ca:	68 00 c5 00 00       	push   $0xc500
801030cf:	68 c0 00 00 00       	push   $0xc0
801030d4:	e8 e0 fd ff ff       	call   80102eb9 <lapicw>
801030d9:	83 c4 08             	add    $0x8,%esp
  microdelay(200);
801030dc:	68 c8 00 00 00       	push   $0xc8
801030e1:	e8 85 ff ff ff       	call   8010306b <microdelay>
801030e6:	83 c4 04             	add    $0x4,%esp
  lapicw(ICRLO, INIT | LEVEL);
801030e9:	68 00 85 00 00       	push   $0x8500
801030ee:	68 c0 00 00 00       	push   $0xc0
801030f3:	e8 c1 fd ff ff       	call   80102eb9 <lapicw>
801030f8:	83 c4 08             	add    $0x8,%esp
  microdelay(100);    // should be 10ms, but too slow in Bochs!
801030fb:	6a 64                	push   $0x64
801030fd:	e8 69 ff ff ff       	call   8010306b <microdelay>
80103102:	83 c4 04             	add    $0x4,%esp
  // Send startup IPI (twice!) to enter code.
  // Regular hardware is supposed to only accept a STARTUP
  // when it is in the halted state due to an INIT.  So the second
  // should be ignored, but it is part of the official Intel algorithm.
  // Bochs complains about the second one.  Too bad for Bochs.
  for(i = 0; i < 2; i++){
80103105:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
8010310c:	eb 3d                	jmp    8010314b <lapicstartap+0xda>
    lapicw(ICRHI, apicid<<24);
8010310e:	0f b6 45 ec          	movzbl -0x14(%ebp),%eax
80103112:	c1 e0 18             	shl    $0x18,%eax
80103115:	50                   	push   %eax
80103116:	68 c4 00 00 00       	push   $0xc4
8010311b:	e8 99 fd ff ff       	call   80102eb9 <lapicw>
80103120:	83 c4 08             	add    $0x8,%esp
    lapicw(ICRLO, STARTUP | (addr>>12));
80103123:	8b 45 0c             	mov    0xc(%ebp),%eax
80103126:	c1 e8 0c             	shr    $0xc,%eax
80103129:	80 cc 06             	or     $0x6,%ah
8010312c:	50                   	push   %eax
8010312d:	68 c0 00 00 00       	push   $0xc0
80103132:	e8 82 fd ff ff       	call   80102eb9 <lapicw>
80103137:	83 c4 08             	add    $0x8,%esp
    microdelay(200);
8010313a:	68 c8 00 00 00       	push   $0xc8
8010313f:	e8 27 ff ff ff       	call   8010306b <microdelay>
80103144:	83 c4 04             	add    $0x4,%esp
  for(i = 0; i < 2; i++){
80103147:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
8010314b:	83 7d fc 01          	cmpl   $0x1,-0x4(%ebp)
8010314f:	7e bd                	jle    8010310e <lapicstartap+0x9d>
  }
}
80103151:	90                   	nop
80103152:	90                   	nop
80103153:	c9                   	leave
80103154:	c3                   	ret

80103155 <cmos_read>:
#define DAY     0x07
#define MONTH   0x08
#define YEAR    0x09

static uint cmos_read(uint reg)
{
80103155:	55                   	push   %ebp
80103156:	89 e5                	mov    %esp,%ebp
  outb(CMOS_PORT,  reg);
80103158:	8b 45 08             	mov    0x8(%ebp),%eax
8010315b:	0f b6 c0             	movzbl %al,%eax
8010315e:	50                   	push   %eax
8010315f:	6a 70                	push   $0x70
80103161:	e8 24 fd ff ff       	call   80102e8a <outb>
80103166:	83 c4 08             	add    $0x8,%esp
  microdelay(200);
80103169:	68 c8 00 00 00       	push   $0xc8
8010316e:	e8 f8 fe ff ff       	call   8010306b <microdelay>
80103173:	83 c4 04             	add    $0x4,%esp

  return inb(CMOS_RETURN);
80103176:	6a 71                	push   $0x71
80103178:	e8 f0 fc ff ff       	call   80102e6d <inb>
8010317d:	83 c4 04             	add    $0x4,%esp
80103180:	0f b6 c0             	movzbl %al,%eax
}
80103183:	c9                   	leave
80103184:	c3                   	ret

80103185 <fill_rtcdate>:

static void fill_rtcdate(struct rtcdate *r)
{
80103185:	55                   	push   %ebp
80103186:	89 e5                	mov    %esp,%ebp
  r->second = cmos_read(SECS);
80103188:	6a 00                	push   $0x0
8010318a:	e8 c6 ff ff ff       	call   80103155 <cmos_read>
8010318f:	83 c4 04             	add    $0x4,%esp
80103192:	8b 55 08             	mov    0x8(%ebp),%edx
80103195:	89 02                	mov    %eax,(%edx)
  r->minute = cmos_read(MINS);
80103197:	6a 02                	push   $0x2
80103199:	e8 b7 ff ff ff       	call   80103155 <cmos_read>
8010319e:	83 c4 04             	add    $0x4,%esp
801031a1:	8b 55 08             	mov    0x8(%ebp),%edx
801031a4:	89 42 04             	mov    %eax,0x4(%edx)
  r->hour   = cmos_read(HOURS);
801031a7:	6a 04                	push   $0x4
801031a9:	e8 a7 ff ff ff       	call   80103155 <cmos_read>
801031ae:	83 c4 04             	add    $0x4,%esp
801031b1:	8b 55 08             	mov    0x8(%ebp),%edx
801031b4:	89 42 08             	mov    %eax,0x8(%edx)
  r->day    = cmos_read(DAY);
801031b7:	6a 07                	push   $0x7
801031b9:	e8 97 ff ff ff       	call   80103155 <cmos_read>
801031be:	83 c4 04             	add    $0x4,%esp
801031c1:	8b 55 08             	mov    0x8(%ebp),%edx
801031c4:	89 42 0c             	mov    %eax,0xc(%edx)
  r->month  = cmos_read(MONTH);
801031c7:	6a 08                	push   $0x8
801031c9:	e8 87 ff ff ff       	call   80103155 <cmos_read>
801031ce:	83 c4 04             	add    $0x4,%esp
801031d1:	8b 55 08             	mov    0x8(%ebp),%edx
801031d4:	89 42 10             	mov    %eax,0x10(%edx)
  r->year   = cmos_read(YEAR);
801031d7:	6a 09                	push   $0x9
801031d9:	e8 77 ff ff ff       	call   80103155 <cmos_read>
801031de:	83 c4 04             	add    $0x4,%esp
801031e1:	8b 55 08             	mov    0x8(%ebp),%edx
801031e4:	89 42 14             	mov    %eax,0x14(%edx)
}
801031e7:	90                   	nop
801031e8:	c9                   	leave
801031e9:	c3                   	ret

801031ea <cmostime>:

// qemu seems to use 24-hour GWT and the values are BCD encoded
void cmostime(struct rtcdate *r)
{
801031ea:	55                   	push   %ebp
801031eb:	89 e5                	mov    %esp,%ebp
801031ed:	83 ec 48             	sub    $0x48,%esp
  struct rtcdate t1, t2;
  int sb, bcd;

  sb = cmos_read(CMOS_STATB);
801031f0:	6a 0b                	push   $0xb
801031f2:	e8 5e ff ff ff       	call   80103155 <cmos_read>
801031f7:	83 c4 04             	add    $0x4,%esp
801031fa:	89 45 f4             	mov    %eax,-0xc(%ebp)

  bcd = (sb & (1 << 2)) == 0;
801031fd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103200:	83 e0 04             	and    $0x4,%eax
80103203:	85 c0                	test   %eax,%eax
80103205:	0f 94 c0             	sete   %al
80103208:	0f b6 c0             	movzbl %al,%eax
8010320b:	89 45 f0             	mov    %eax,-0x10(%ebp)

  // make sure CMOS doesn't modify time while we read it
  for (;;) {
    fill_rtcdate(&t1);
8010320e:	8d 45 d8             	lea    -0x28(%ebp),%eax
80103211:	50                   	push   %eax
80103212:	e8 6e ff ff ff       	call   80103185 <fill_rtcdate>
80103217:	83 c4 04             	add    $0x4,%esp
    if (cmos_read(CMOS_STATA) & CMOS_UIP)
8010321a:	6a 0a                	push   $0xa
8010321c:	e8 34 ff ff ff       	call   80103155 <cmos_read>
80103221:	83 c4 04             	add    $0x4,%esp
80103224:	25 80 00 00 00       	and    $0x80,%eax
80103229:	85 c0                	test   %eax,%eax
8010322b:	75 27                	jne    80103254 <cmostime+0x6a>
        continue;
    fill_rtcdate(&t2);
8010322d:	8d 45 c0             	lea    -0x40(%ebp),%eax
80103230:	50                   	push   %eax
80103231:	e8 4f ff ff ff       	call   80103185 <fill_rtcdate>
80103236:	83 c4 04             	add    $0x4,%esp
    if (memcmp(&t1, &t2, sizeof(t1)) == 0)
80103239:	83 ec 04             	sub    $0x4,%esp
8010323c:	6a 18                	push   $0x18
8010323e:	8d 45 c0             	lea    -0x40(%ebp),%eax
80103241:	50                   	push   %eax
80103242:	8d 45 d8             	lea    -0x28(%ebp),%eax
80103245:	50                   	push   %eax
80103246:	e8 ff 20 00 00       	call   8010534a <memcmp>
8010324b:	83 c4 10             	add    $0x10,%esp
8010324e:	85 c0                	test   %eax,%eax
80103250:	74 05                	je     80103257 <cmostime+0x6d>
80103252:	eb ba                	jmp    8010320e <cmostime+0x24>
        continue;
80103254:	90                   	nop
    fill_rtcdate(&t1);
80103255:	eb b7                	jmp    8010320e <cmostime+0x24>
      break;
80103257:	90                   	nop
  }

  // convert
  if (bcd) {
80103258:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010325c:	0f 84 b4 00 00 00    	je     80103316 <cmostime+0x12c>
#define    CONV(x)     (t1.x = ((t1.x >> 4) * 10) + (t1.x & 0xf))
    CONV(second);
80103262:	8b 45 d8             	mov    -0x28(%ebp),%eax
80103265:	c1 e8 04             	shr    $0x4,%eax
80103268:	89 c2                	mov    %eax,%edx
8010326a:	89 d0                	mov    %edx,%eax
8010326c:	c1 e0 02             	shl    $0x2,%eax
8010326f:	01 d0                	add    %edx,%eax
80103271:	01 c0                	add    %eax,%eax
80103273:	89 c2                	mov    %eax,%edx
80103275:	8b 45 d8             	mov    -0x28(%ebp),%eax
80103278:	83 e0 0f             	and    $0xf,%eax
8010327b:	01 d0                	add    %edx,%eax
8010327d:	89 45 d8             	mov    %eax,-0x28(%ebp)
    CONV(minute);
80103280:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103283:	c1 e8 04             	shr    $0x4,%eax
80103286:	89 c2                	mov    %eax,%edx
80103288:	89 d0                	mov    %edx,%eax
8010328a:	c1 e0 02             	shl    $0x2,%eax
8010328d:	01 d0                	add    %edx,%eax
8010328f:	01 c0                	add    %eax,%eax
80103291:	89 c2                	mov    %eax,%edx
80103293:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103296:	83 e0 0f             	and    $0xf,%eax
80103299:	01 d0                	add    %edx,%eax
8010329b:	89 45 dc             	mov    %eax,-0x24(%ebp)
    CONV(hour  );
8010329e:	8b 45 e0             	mov    -0x20(%ebp),%eax
801032a1:	c1 e8 04             	shr    $0x4,%eax
801032a4:	89 c2                	mov    %eax,%edx
801032a6:	89 d0                	mov    %edx,%eax
801032a8:	c1 e0 02             	shl    $0x2,%eax
801032ab:	01 d0                	add    %edx,%eax
801032ad:	01 c0                	add    %eax,%eax
801032af:	89 c2                	mov    %eax,%edx
801032b1:	8b 45 e0             	mov    -0x20(%ebp),%eax
801032b4:	83 e0 0f             	and    $0xf,%eax
801032b7:	01 d0                	add    %edx,%eax
801032b9:	89 45 e0             	mov    %eax,-0x20(%ebp)
    CONV(day   );
801032bc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801032bf:	c1 e8 04             	shr    $0x4,%eax
801032c2:	89 c2                	mov    %eax,%edx
801032c4:	89 d0                	mov    %edx,%eax
801032c6:	c1 e0 02             	shl    $0x2,%eax
801032c9:	01 d0                	add    %edx,%eax
801032cb:	01 c0                	add    %eax,%eax
801032cd:	89 c2                	mov    %eax,%edx
801032cf:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801032d2:	83 e0 0f             	and    $0xf,%eax
801032d5:	01 d0                	add    %edx,%eax
801032d7:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    CONV(month );
801032da:	8b 45 e8             	mov    -0x18(%ebp),%eax
801032dd:	c1 e8 04             	shr    $0x4,%eax
801032e0:	89 c2                	mov    %eax,%edx
801032e2:	89 d0                	mov    %edx,%eax
801032e4:	c1 e0 02             	shl    $0x2,%eax
801032e7:	01 d0                	add    %edx,%eax
801032e9:	01 c0                	add    %eax,%eax
801032eb:	89 c2                	mov    %eax,%edx
801032ed:	8b 45 e8             	mov    -0x18(%ebp),%eax
801032f0:	83 e0 0f             	and    $0xf,%eax
801032f3:	01 d0                	add    %edx,%eax
801032f5:	89 45 e8             	mov    %eax,-0x18(%ebp)
    CONV(year  );
801032f8:	8b 45 ec             	mov    -0x14(%ebp),%eax
801032fb:	c1 e8 04             	shr    $0x4,%eax
801032fe:	89 c2                	mov    %eax,%edx
80103300:	89 d0                	mov    %edx,%eax
80103302:	c1 e0 02             	shl    $0x2,%eax
80103305:	01 d0                	add    %edx,%eax
80103307:	01 c0                	add    %eax,%eax
80103309:	89 c2                	mov    %eax,%edx
8010330b:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010330e:	83 e0 0f             	and    $0xf,%eax
80103311:	01 d0                	add    %edx,%eax
80103313:	89 45 ec             	mov    %eax,-0x14(%ebp)
#undef     CONV
  }

  *r = t1;
80103316:	8b 45 08             	mov    0x8(%ebp),%eax
80103319:	8b 55 d8             	mov    -0x28(%ebp),%edx
8010331c:	89 10                	mov    %edx,(%eax)
8010331e:	8b 55 dc             	mov    -0x24(%ebp),%edx
80103321:	89 50 04             	mov    %edx,0x4(%eax)
80103324:	8b 55 e0             	mov    -0x20(%ebp),%edx
80103327:	89 50 08             	mov    %edx,0x8(%eax)
8010332a:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010332d:	89 50 0c             	mov    %edx,0xc(%eax)
80103330:	8b 55 e8             	mov    -0x18(%ebp),%edx
80103333:	89 50 10             	mov    %edx,0x10(%eax)
80103336:	8b 55 ec             	mov    -0x14(%ebp),%edx
80103339:	89 50 14             	mov    %edx,0x14(%eax)
  r->year += 2000;
8010333c:	8b 45 08             	mov    0x8(%ebp),%eax
8010333f:	8b 40 14             	mov    0x14(%eax),%eax
80103342:	8d 90 d0 07 00 00    	lea    0x7d0(%eax),%edx
80103348:	8b 45 08             	mov    0x8(%ebp),%eax
8010334b:	89 50 14             	mov    %edx,0x14(%eax)
}
8010334e:	90                   	nop
8010334f:	c9                   	leave
80103350:	c3                   	ret

80103351 <initlog>:
static void recover_from_log(void);
static void commit();

void
initlog(int dev)
{
80103351:	55                   	push   %ebp
80103352:	89 e5                	mov    %esp,%ebp
80103354:	83 ec 28             	sub    $0x28,%esp
  if (sizeof(struct logheader) >= BSIZE)
    panic("initlog: too big logheader");

  struct superblock sb;
  initlock(&log.lock, "log");
80103357:	83 ec 08             	sub    $0x8,%esp
8010335a:	68 7c 8a 10 80       	push   $0x80108a7c
8010335f:	68 80 12 11 80       	push   $0x80111280
80103364:	e8 f4 1c 00 00       	call   8010505d <initlock>
80103369:	83 c4 10             	add    $0x10,%esp
  readsb(dev, &sb);
8010336c:	83 ec 08             	sub    $0x8,%esp
8010336f:	8d 45 dc             	lea    -0x24(%ebp),%eax
80103372:	50                   	push   %eax
80103373:	ff 75 08             	push   0x8(%ebp)
80103376:	e8 3a e0 ff ff       	call   801013b5 <readsb>
8010337b:	83 c4 10             	add    $0x10,%esp
  log.start = sb.logstart;
8010337e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103381:	a3 b4 12 11 80       	mov    %eax,0x801112b4
  log.size = sb.nlog;
80103386:	8b 45 e8             	mov    -0x18(%ebp),%eax
80103389:	a3 b8 12 11 80       	mov    %eax,0x801112b8
  log.dev = dev;
8010338e:	8b 45 08             	mov    0x8(%ebp),%eax
80103391:	a3 c4 12 11 80       	mov    %eax,0x801112c4
  recover_from_log();
80103396:	e8 b3 01 00 00       	call   8010354e <recover_from_log>
}
8010339b:	90                   	nop
8010339c:	c9                   	leave
8010339d:	c3                   	ret

8010339e <install_trans>:

// Copy committed blocks from log to their home location
static void 
install_trans(void)
{
8010339e:	55                   	push   %ebp
8010339f:	89 e5                	mov    %esp,%ebp
801033a1:	83 ec 18             	sub    $0x18,%esp
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
801033a4:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801033ab:	e9 95 00 00 00       	jmp    80103445 <install_trans+0xa7>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
801033b0:	8b 15 b4 12 11 80    	mov    0x801112b4,%edx
801033b6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801033b9:	01 d0                	add    %edx,%eax
801033bb:	83 c0 01             	add    $0x1,%eax
801033be:	89 c2                	mov    %eax,%edx
801033c0:	a1 c4 12 11 80       	mov    0x801112c4,%eax
801033c5:	83 ec 08             	sub    $0x8,%esp
801033c8:	52                   	push   %edx
801033c9:	50                   	push   %eax
801033ca:	e8 e8 cd ff ff       	call   801001b7 <bread>
801033cf:	83 c4 10             	add    $0x10,%esp
801033d2:	89 45 f0             	mov    %eax,-0x10(%ebp)
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
801033d5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801033d8:	83 c0 10             	add    $0x10,%eax
801033db:	8b 04 85 8c 12 11 80 	mov    -0x7feeed74(,%eax,4),%eax
801033e2:	89 c2                	mov    %eax,%edx
801033e4:	a1 c4 12 11 80       	mov    0x801112c4,%eax
801033e9:	83 ec 08             	sub    $0x8,%esp
801033ec:	52                   	push   %edx
801033ed:	50                   	push   %eax
801033ee:	e8 c4 cd ff ff       	call   801001b7 <bread>
801033f3:	83 c4 10             	add    $0x10,%esp
801033f6:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
801033f9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801033fc:	8d 50 18             	lea    0x18(%eax),%edx
801033ff:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103402:	83 c0 18             	add    $0x18,%eax
80103405:	83 ec 04             	sub    $0x4,%esp
80103408:	68 00 02 00 00       	push   $0x200
8010340d:	52                   	push   %edx
8010340e:	50                   	push   %eax
8010340f:	e8 8e 1f 00 00       	call   801053a2 <memmove>
80103414:	83 c4 10             	add    $0x10,%esp
    bwrite(dbuf);  // write dst to disk
80103417:	83 ec 0c             	sub    $0xc,%esp
8010341a:	ff 75 ec             	push   -0x14(%ebp)
8010341d:	e8 ce cd ff ff       	call   801001f0 <bwrite>
80103422:	83 c4 10             	add    $0x10,%esp
    brelse(lbuf); 
80103425:	83 ec 0c             	sub    $0xc,%esp
80103428:	ff 75 f0             	push   -0x10(%ebp)
8010342b:	e8 ff cd ff ff       	call   8010022f <brelse>
80103430:	83 c4 10             	add    $0x10,%esp
    brelse(dbuf);
80103433:	83 ec 0c             	sub    $0xc,%esp
80103436:	ff 75 ec             	push   -0x14(%ebp)
80103439:	e8 f1 cd ff ff       	call   8010022f <brelse>
8010343e:	83 c4 10             	add    $0x10,%esp
  for (tail = 0; tail < log.lh.n; tail++) {
80103441:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103445:	a1 c8 12 11 80       	mov    0x801112c8,%eax
8010344a:	39 45 f4             	cmp    %eax,-0xc(%ebp)
8010344d:	0f 8c 5d ff ff ff    	jl     801033b0 <install_trans+0x12>
  }
}
80103453:	90                   	nop
80103454:	90                   	nop
80103455:	c9                   	leave
80103456:	c3                   	ret

80103457 <read_head>:

// Read the log header from disk into the in-memory log header
static void
read_head(void)
{
80103457:	55                   	push   %ebp
80103458:	89 e5                	mov    %esp,%ebp
8010345a:	83 ec 18             	sub    $0x18,%esp
  struct buf *buf = bread(log.dev, log.start);
8010345d:	a1 b4 12 11 80       	mov    0x801112b4,%eax
80103462:	89 c2                	mov    %eax,%edx
80103464:	a1 c4 12 11 80       	mov    0x801112c4,%eax
80103469:	83 ec 08             	sub    $0x8,%esp
8010346c:	52                   	push   %edx
8010346d:	50                   	push   %eax
8010346e:	e8 44 cd ff ff       	call   801001b7 <bread>
80103473:	83 c4 10             	add    $0x10,%esp
80103476:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct logheader *lh = (struct logheader *) (buf->data);
80103479:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010347c:	83 c0 18             	add    $0x18,%eax
8010347f:	89 45 ec             	mov    %eax,-0x14(%ebp)
  int i;
  log.lh.n = lh->n;
80103482:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103485:	8b 00                	mov    (%eax),%eax
80103487:	a3 c8 12 11 80       	mov    %eax,0x801112c8
  for (i = 0; i < log.lh.n; i++) {
8010348c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103493:	eb 1b                	jmp    801034b0 <read_head+0x59>
    log.lh.block[i] = lh->block[i];
80103495:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103498:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010349b:	8b 44 90 04          	mov    0x4(%eax,%edx,4),%eax
8010349f:	8b 55 f4             	mov    -0xc(%ebp),%edx
801034a2:	83 c2 10             	add    $0x10,%edx
801034a5:	89 04 95 8c 12 11 80 	mov    %eax,-0x7feeed74(,%edx,4)
  for (i = 0; i < log.lh.n; i++) {
801034ac:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801034b0:	a1 c8 12 11 80       	mov    0x801112c8,%eax
801034b5:	39 45 f4             	cmp    %eax,-0xc(%ebp)
801034b8:	7c db                	jl     80103495 <read_head+0x3e>
  }
  brelse(buf);
801034ba:	83 ec 0c             	sub    $0xc,%esp
801034bd:	ff 75 f0             	push   -0x10(%ebp)
801034c0:	e8 6a cd ff ff       	call   8010022f <brelse>
801034c5:	83 c4 10             	add    $0x10,%esp
}
801034c8:	90                   	nop
801034c9:	c9                   	leave
801034ca:	c3                   	ret

801034cb <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
801034cb:	55                   	push   %ebp
801034cc:	89 e5                	mov    %esp,%ebp
801034ce:	83 ec 18             	sub    $0x18,%esp
  struct buf *buf = bread(log.dev, log.start);
801034d1:	a1 b4 12 11 80       	mov    0x801112b4,%eax
801034d6:	89 c2                	mov    %eax,%edx
801034d8:	a1 c4 12 11 80       	mov    0x801112c4,%eax
801034dd:	83 ec 08             	sub    $0x8,%esp
801034e0:	52                   	push   %edx
801034e1:	50                   	push   %eax
801034e2:	e8 d0 cc ff ff       	call   801001b7 <bread>
801034e7:	83 c4 10             	add    $0x10,%esp
801034ea:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct logheader *hb = (struct logheader *) (buf->data);
801034ed:	8b 45 f0             	mov    -0x10(%ebp),%eax
801034f0:	83 c0 18             	add    $0x18,%eax
801034f3:	89 45 ec             	mov    %eax,-0x14(%ebp)
  int i;
  hb->n = log.lh.n;
801034f6:	8b 15 c8 12 11 80    	mov    0x801112c8,%edx
801034fc:	8b 45 ec             	mov    -0x14(%ebp),%eax
801034ff:	89 10                	mov    %edx,(%eax)
  for (i = 0; i < log.lh.n; i++) {
80103501:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103508:	eb 1b                	jmp    80103525 <write_head+0x5a>
    hb->block[i] = log.lh.block[i];
8010350a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010350d:	83 c0 10             	add    $0x10,%eax
80103510:	8b 0c 85 8c 12 11 80 	mov    -0x7feeed74(,%eax,4),%ecx
80103517:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010351a:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010351d:	89 4c 90 04          	mov    %ecx,0x4(%eax,%edx,4)
  for (i = 0; i < log.lh.n; i++) {
80103521:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103525:	a1 c8 12 11 80       	mov    0x801112c8,%eax
8010352a:	39 45 f4             	cmp    %eax,-0xc(%ebp)
8010352d:	7c db                	jl     8010350a <write_head+0x3f>
  }
  bwrite(buf);
8010352f:	83 ec 0c             	sub    $0xc,%esp
80103532:	ff 75 f0             	push   -0x10(%ebp)
80103535:	e8 b6 cc ff ff       	call   801001f0 <bwrite>
8010353a:	83 c4 10             	add    $0x10,%esp
  brelse(buf);
8010353d:	83 ec 0c             	sub    $0xc,%esp
80103540:	ff 75 f0             	push   -0x10(%ebp)
80103543:	e8 e7 cc ff ff       	call   8010022f <brelse>
80103548:	83 c4 10             	add    $0x10,%esp
}
8010354b:	90                   	nop
8010354c:	c9                   	leave
8010354d:	c3                   	ret

8010354e <recover_from_log>:

static void
recover_from_log(void)
{
8010354e:	55                   	push   %ebp
8010354f:	89 e5                	mov    %esp,%ebp
80103551:	83 ec 08             	sub    $0x8,%esp
  read_head();      
80103554:	e8 fe fe ff ff       	call   80103457 <read_head>
  install_trans(); // if committed, copy from log to disk
80103559:	e8 40 fe ff ff       	call   8010339e <install_trans>
  log.lh.n = 0;
8010355e:	c7 05 c8 12 11 80 00 	movl   $0x0,0x801112c8
80103565:	00 00 00 
  write_head(); // clear the log
80103568:	e8 5e ff ff ff       	call   801034cb <write_head>
}
8010356d:	90                   	nop
8010356e:	c9                   	leave
8010356f:	c3                   	ret

80103570 <begin_op>:

// called at the start of each FS system call.
void
begin_op(void)
{
80103570:	55                   	push   %ebp
80103571:	89 e5                	mov    %esp,%ebp
80103573:	83 ec 08             	sub    $0x8,%esp
  acquire(&log.lock);
80103576:	83 ec 0c             	sub    $0xc,%esp
80103579:	68 80 12 11 80       	push   $0x80111280
8010357e:	e8 fc 1a 00 00       	call   8010507f <acquire>
80103583:	83 c4 10             	add    $0x10,%esp
  while(1){
    if(log.committing){
80103586:	a1 c0 12 11 80       	mov    0x801112c0,%eax
8010358b:	85 c0                	test   %eax,%eax
8010358d:	74 17                	je     801035a6 <begin_op+0x36>
      sleep(&log, &log.lock);
8010358f:	83 ec 08             	sub    $0x8,%esp
80103592:	68 80 12 11 80       	push   $0x80111280
80103597:	68 80 12 11 80       	push   $0x80111280
8010359c:	e8 e3 17 00 00       	call   80104d84 <sleep>
801035a1:	83 c4 10             	add    $0x10,%esp
801035a4:	eb e0                	jmp    80103586 <begin_op+0x16>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
801035a6:	8b 0d c8 12 11 80    	mov    0x801112c8,%ecx
801035ac:	a1 bc 12 11 80       	mov    0x801112bc,%eax
801035b1:	8d 50 01             	lea    0x1(%eax),%edx
801035b4:	89 d0                	mov    %edx,%eax
801035b6:	c1 e0 02             	shl    $0x2,%eax
801035b9:	01 d0                	add    %edx,%eax
801035bb:	01 c0                	add    %eax,%eax
801035bd:	01 c8                	add    %ecx,%eax
801035bf:	83 f8 1e             	cmp    $0x1e,%eax
801035c2:	7e 17                	jle    801035db <begin_op+0x6b>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
801035c4:	83 ec 08             	sub    $0x8,%esp
801035c7:	68 80 12 11 80       	push   $0x80111280
801035cc:	68 80 12 11 80       	push   $0x80111280
801035d1:	e8 ae 17 00 00       	call   80104d84 <sleep>
801035d6:	83 c4 10             	add    $0x10,%esp
801035d9:	eb ab                	jmp    80103586 <begin_op+0x16>
    } else {
      log.outstanding += 1;
801035db:	a1 bc 12 11 80       	mov    0x801112bc,%eax
801035e0:	83 c0 01             	add    $0x1,%eax
801035e3:	a3 bc 12 11 80       	mov    %eax,0x801112bc
      release(&log.lock);
801035e8:	83 ec 0c             	sub    $0xc,%esp
801035eb:	68 80 12 11 80       	push   $0x80111280
801035f0:	e8 f1 1a 00 00       	call   801050e6 <release>
801035f5:	83 c4 10             	add    $0x10,%esp
      break;
801035f8:	90                   	nop
    }
  }
}
801035f9:	90                   	nop
801035fa:	c9                   	leave
801035fb:	c3                   	ret

801035fc <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
801035fc:	55                   	push   %ebp
801035fd:	89 e5                	mov    %esp,%ebp
801035ff:	83 ec 18             	sub    $0x18,%esp
  int do_commit = 0;
80103602:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

  acquire(&log.lock);
80103609:	83 ec 0c             	sub    $0xc,%esp
8010360c:	68 80 12 11 80       	push   $0x80111280
80103611:	e8 69 1a 00 00       	call   8010507f <acquire>
80103616:	83 c4 10             	add    $0x10,%esp
  log.outstanding -= 1;
80103619:	a1 bc 12 11 80       	mov    0x801112bc,%eax
8010361e:	83 e8 01             	sub    $0x1,%eax
80103621:	a3 bc 12 11 80       	mov    %eax,0x801112bc
  if(log.committing)
80103626:	a1 c0 12 11 80       	mov    0x801112c0,%eax
8010362b:	85 c0                	test   %eax,%eax
8010362d:	74 0d                	je     8010363c <end_op+0x40>
    panic("log.committing");
8010362f:	83 ec 0c             	sub    $0xc,%esp
80103632:	68 80 8a 10 80       	push   $0x80108a80
80103637:	e8 3d cf ff ff       	call   80100579 <panic>
  if(log.outstanding == 0){
8010363c:	a1 bc 12 11 80       	mov    0x801112bc,%eax
80103641:	85 c0                	test   %eax,%eax
80103643:	75 13                	jne    80103658 <end_op+0x5c>
    do_commit = 1;
80103645:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
    log.committing = 1;
8010364c:	c7 05 c0 12 11 80 01 	movl   $0x1,0x801112c0
80103653:	00 00 00 
80103656:	eb 10                	jmp    80103668 <end_op+0x6c>
  } else {
    // begin_op() may be waiting for log space.
    wakeup(&log);
80103658:	83 ec 0c             	sub    $0xc,%esp
8010365b:	68 80 12 11 80       	push   $0x80111280
80103660:	e8 0b 18 00 00       	call   80104e70 <wakeup>
80103665:	83 c4 10             	add    $0x10,%esp
  }
  release(&log.lock);
80103668:	83 ec 0c             	sub    $0xc,%esp
8010366b:	68 80 12 11 80       	push   $0x80111280
80103670:	e8 71 1a 00 00       	call   801050e6 <release>
80103675:	83 c4 10             	add    $0x10,%esp

  if(do_commit){
80103678:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010367c:	74 3f                	je     801036bd <end_op+0xc1>
    // call commit w/o holding locks, since not allowed
    // to sleep with locks.
    commit();
8010367e:	e8 f6 00 00 00       	call   80103779 <commit>
    acquire(&log.lock);
80103683:	83 ec 0c             	sub    $0xc,%esp
80103686:	68 80 12 11 80       	push   $0x80111280
8010368b:	e8 ef 19 00 00       	call   8010507f <acquire>
80103690:	83 c4 10             	add    $0x10,%esp
    log.committing = 0;
80103693:	c7 05 c0 12 11 80 00 	movl   $0x0,0x801112c0
8010369a:	00 00 00 
    wakeup(&log);
8010369d:	83 ec 0c             	sub    $0xc,%esp
801036a0:	68 80 12 11 80       	push   $0x80111280
801036a5:	e8 c6 17 00 00       	call   80104e70 <wakeup>
801036aa:	83 c4 10             	add    $0x10,%esp
    release(&log.lock);
801036ad:	83 ec 0c             	sub    $0xc,%esp
801036b0:	68 80 12 11 80       	push   $0x80111280
801036b5:	e8 2c 1a 00 00       	call   801050e6 <release>
801036ba:	83 c4 10             	add    $0x10,%esp
  }
}
801036bd:	90                   	nop
801036be:	c9                   	leave
801036bf:	c3                   	ret

801036c0 <write_log>:

// Copy modified blocks from cache to log.
static void 
write_log(void)
{
801036c0:	55                   	push   %ebp
801036c1:	89 e5                	mov    %esp,%ebp
801036c3:	83 ec 18             	sub    $0x18,%esp
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
801036c6:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801036cd:	e9 95 00 00 00       	jmp    80103767 <write_log+0xa7>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
801036d2:	8b 15 b4 12 11 80    	mov    0x801112b4,%edx
801036d8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801036db:	01 d0                	add    %edx,%eax
801036dd:	83 c0 01             	add    $0x1,%eax
801036e0:	89 c2                	mov    %eax,%edx
801036e2:	a1 c4 12 11 80       	mov    0x801112c4,%eax
801036e7:	83 ec 08             	sub    $0x8,%esp
801036ea:	52                   	push   %edx
801036eb:	50                   	push   %eax
801036ec:	e8 c6 ca ff ff       	call   801001b7 <bread>
801036f1:	83 c4 10             	add    $0x10,%esp
801036f4:	89 45 f0             	mov    %eax,-0x10(%ebp)
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
801036f7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801036fa:	83 c0 10             	add    $0x10,%eax
801036fd:	8b 04 85 8c 12 11 80 	mov    -0x7feeed74(,%eax,4),%eax
80103704:	89 c2                	mov    %eax,%edx
80103706:	a1 c4 12 11 80       	mov    0x801112c4,%eax
8010370b:	83 ec 08             	sub    $0x8,%esp
8010370e:	52                   	push   %edx
8010370f:	50                   	push   %eax
80103710:	e8 a2 ca ff ff       	call   801001b7 <bread>
80103715:	83 c4 10             	add    $0x10,%esp
80103718:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(to->data, from->data, BSIZE);
8010371b:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010371e:	8d 50 18             	lea    0x18(%eax),%edx
80103721:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103724:	83 c0 18             	add    $0x18,%eax
80103727:	83 ec 04             	sub    $0x4,%esp
8010372a:	68 00 02 00 00       	push   $0x200
8010372f:	52                   	push   %edx
80103730:	50                   	push   %eax
80103731:	e8 6c 1c 00 00       	call   801053a2 <memmove>
80103736:	83 c4 10             	add    $0x10,%esp
    bwrite(to);  // write the log
80103739:	83 ec 0c             	sub    $0xc,%esp
8010373c:	ff 75 f0             	push   -0x10(%ebp)
8010373f:	e8 ac ca ff ff       	call   801001f0 <bwrite>
80103744:	83 c4 10             	add    $0x10,%esp
    brelse(from); 
80103747:	83 ec 0c             	sub    $0xc,%esp
8010374a:	ff 75 ec             	push   -0x14(%ebp)
8010374d:	e8 dd ca ff ff       	call   8010022f <brelse>
80103752:	83 c4 10             	add    $0x10,%esp
    brelse(to);
80103755:	83 ec 0c             	sub    $0xc,%esp
80103758:	ff 75 f0             	push   -0x10(%ebp)
8010375b:	e8 cf ca ff ff       	call   8010022f <brelse>
80103760:	83 c4 10             	add    $0x10,%esp
  for (tail = 0; tail < log.lh.n; tail++) {
80103763:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103767:	a1 c8 12 11 80       	mov    0x801112c8,%eax
8010376c:	39 45 f4             	cmp    %eax,-0xc(%ebp)
8010376f:	0f 8c 5d ff ff ff    	jl     801036d2 <write_log+0x12>
  }
}
80103775:	90                   	nop
80103776:	90                   	nop
80103777:	c9                   	leave
80103778:	c3                   	ret

80103779 <commit>:

static void
commit()
{
80103779:	55                   	push   %ebp
8010377a:	89 e5                	mov    %esp,%ebp
8010377c:	83 ec 08             	sub    $0x8,%esp
  if (log.lh.n > 0) {
8010377f:	a1 c8 12 11 80       	mov    0x801112c8,%eax
80103784:	85 c0                	test   %eax,%eax
80103786:	7e 1e                	jle    801037a6 <commit+0x2d>
    write_log();     // Write modified blocks from cache to log
80103788:	e8 33 ff ff ff       	call   801036c0 <write_log>
    write_head();    // Write header to disk -- the real commit
8010378d:	e8 39 fd ff ff       	call   801034cb <write_head>
    install_trans(); // Now install writes to home locations
80103792:	e8 07 fc ff ff       	call   8010339e <install_trans>
    log.lh.n = 0; 
80103797:	c7 05 c8 12 11 80 00 	movl   $0x0,0x801112c8
8010379e:	00 00 00 
    write_head();    // Erase the transaction from the log
801037a1:	e8 25 fd ff ff       	call   801034cb <write_head>
  }
}
801037a6:	90                   	nop
801037a7:	c9                   	leave
801037a8:	c3                   	ret

801037a9 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
801037a9:	55                   	push   %ebp
801037aa:	89 e5                	mov    %esp,%ebp
801037ac:	83 ec 18             	sub    $0x18,%esp
  int i;

  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
801037af:	a1 c8 12 11 80       	mov    0x801112c8,%eax
801037b4:	83 f8 1d             	cmp    $0x1d,%eax
801037b7:	7f 12                	jg     801037cb <log_write+0x22>
801037b9:	8b 15 c8 12 11 80    	mov    0x801112c8,%edx
801037bf:	a1 b8 12 11 80       	mov    0x801112b8,%eax
801037c4:	83 e8 01             	sub    $0x1,%eax
801037c7:	39 c2                	cmp    %eax,%edx
801037c9:	7c 0d                	jl     801037d8 <log_write+0x2f>
    panic("too big a transaction");
801037cb:	83 ec 0c             	sub    $0xc,%esp
801037ce:	68 8f 8a 10 80       	push   $0x80108a8f
801037d3:	e8 a1 cd ff ff       	call   80100579 <panic>
  if (log.outstanding < 1)
801037d8:	a1 bc 12 11 80       	mov    0x801112bc,%eax
801037dd:	85 c0                	test   %eax,%eax
801037df:	7f 0d                	jg     801037ee <log_write+0x45>
    panic("log_write outside of trans");
801037e1:	83 ec 0c             	sub    $0xc,%esp
801037e4:	68 a5 8a 10 80       	push   $0x80108aa5
801037e9:	e8 8b cd ff ff       	call   80100579 <panic>

  acquire(&log.lock);
801037ee:	83 ec 0c             	sub    $0xc,%esp
801037f1:	68 80 12 11 80       	push   $0x80111280
801037f6:	e8 84 18 00 00       	call   8010507f <acquire>
801037fb:	83 c4 10             	add    $0x10,%esp
  for (i = 0; i < log.lh.n; i++) {
801037fe:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103805:	eb 1d                	jmp    80103824 <log_write+0x7b>
    if (log.lh.block[i] == b->blockno)   // log absorbtion
80103807:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010380a:	83 c0 10             	add    $0x10,%eax
8010380d:	8b 04 85 8c 12 11 80 	mov    -0x7feeed74(,%eax,4),%eax
80103814:	89 c2                	mov    %eax,%edx
80103816:	8b 45 08             	mov    0x8(%ebp),%eax
80103819:	8b 40 08             	mov    0x8(%eax),%eax
8010381c:	39 c2                	cmp    %eax,%edx
8010381e:	74 10                	je     80103830 <log_write+0x87>
  for (i = 0; i < log.lh.n; i++) {
80103820:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103824:	a1 c8 12 11 80       	mov    0x801112c8,%eax
80103829:	39 45 f4             	cmp    %eax,-0xc(%ebp)
8010382c:	7c d9                	jl     80103807 <log_write+0x5e>
8010382e:	eb 01                	jmp    80103831 <log_write+0x88>
      break;
80103830:	90                   	nop
  }
  log.lh.block[i] = b->blockno;
80103831:	8b 45 08             	mov    0x8(%ebp),%eax
80103834:	8b 40 08             	mov    0x8(%eax),%eax
80103837:	89 c2                	mov    %eax,%edx
80103839:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010383c:	83 c0 10             	add    $0x10,%eax
8010383f:	89 14 85 8c 12 11 80 	mov    %edx,-0x7feeed74(,%eax,4)
  if (i == log.lh.n)
80103846:	a1 c8 12 11 80       	mov    0x801112c8,%eax
8010384b:	39 45 f4             	cmp    %eax,-0xc(%ebp)
8010384e:	75 0d                	jne    8010385d <log_write+0xb4>
    log.lh.n++;
80103850:	a1 c8 12 11 80       	mov    0x801112c8,%eax
80103855:	83 c0 01             	add    $0x1,%eax
80103858:	a3 c8 12 11 80       	mov    %eax,0x801112c8
  b->flags |= B_DIRTY; // prevent eviction
8010385d:	8b 45 08             	mov    0x8(%ebp),%eax
80103860:	8b 00                	mov    (%eax),%eax
80103862:	83 c8 04             	or     $0x4,%eax
80103865:	89 c2                	mov    %eax,%edx
80103867:	8b 45 08             	mov    0x8(%ebp),%eax
8010386a:	89 10                	mov    %edx,(%eax)
  release(&log.lock);
8010386c:	83 ec 0c             	sub    $0xc,%esp
8010386f:	68 80 12 11 80       	push   $0x80111280
80103874:	e8 6d 18 00 00       	call   801050e6 <release>
80103879:	83 c4 10             	add    $0x10,%esp
}
8010387c:	90                   	nop
8010387d:	c9                   	leave
8010387e:	c3                   	ret

8010387f <v2p>:
8010387f:	55                   	push   %ebp
80103880:	89 e5                	mov    %esp,%ebp
80103882:	8b 45 08             	mov    0x8(%ebp),%eax
80103885:	05 00 00 00 80       	add    $0x80000000,%eax
8010388a:	5d                   	pop    %ebp
8010388b:	c3                   	ret

8010388c <p2v>:
static inline void *p2v(uint a) { return (void *) ((a) + KERNBASE); }
8010388c:	55                   	push   %ebp
8010388d:	89 e5                	mov    %esp,%ebp
8010388f:	8b 45 08             	mov    0x8(%ebp),%eax
80103892:	05 00 00 00 80       	add    $0x80000000,%eax
80103897:	5d                   	pop    %ebp
80103898:	c3                   	ret

80103899 <xchg>:
  asm volatile("sti");
}

static inline uint
xchg(volatile uint *addr, uint newval)
{
80103899:	55                   	push   %ebp
8010389a:	89 e5                	mov    %esp,%ebp
8010389c:	83 ec 10             	sub    $0x10,%esp
  uint result;
  
  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
8010389f:	8b 55 08             	mov    0x8(%ebp),%edx
801038a2:	8b 45 0c             	mov    0xc(%ebp),%eax
801038a5:	8b 4d 08             	mov    0x8(%ebp),%ecx
801038a8:	f0 87 02             	lock xchg %eax,(%edx)
801038ab:	89 45 fc             	mov    %eax,-0x4(%ebp)
               "+m" (*addr), "=a" (result) :
               "1" (newval) :
               "cc");
  return result;
801038ae:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
801038b1:	c9                   	leave
801038b2:	c3                   	ret

801038b3 <main>:
// Bootstrap processor starts running C code here.
// Allocate a real stack and switch to it, first
// doing some setup required for memory allocator to work.
int
main(void)
{
801038b3:	8d 4c 24 04          	lea    0x4(%esp),%ecx
801038b7:	83 e4 f0             	and    $0xfffffff0,%esp
801038ba:	ff 71 fc             	push   -0x4(%ecx)
801038bd:	55                   	push   %ebp
801038be:	89 e5                	mov    %esp,%ebp
801038c0:	51                   	push   %ecx
801038c1:	83 ec 04             	sub    $0x4,%esp
  kinit1(end, P2V(4*1024*1024)); // phys page allocator
801038c4:	83 ec 08             	sub    $0x8,%esp
801038c7:	68 00 00 40 80       	push   $0x80400000
801038cc:	68 60 51 11 80       	push   $0x80115160
801038d1:	e8 6b f2 ff ff       	call   80102b41 <kinit1>
801038d6:	83 c4 10             	add    $0x10,%esp
  kvmalloc();      // kernel page table
801038d9:	e8 b4 47 00 00       	call   80108092 <kvmalloc>
  mpinit();        // collect info about this machine
801038de:	e8 38 04 00 00       	call   80103d1b <mpinit>
  lapicinit();
801038e3:	e8 f3 f5 ff ff       	call   80102edb <lapicinit>
  seginit();       // set up segments
801038e8:	e8 4e 41 00 00       	call   80107a3b <seginit>
  cprintf("\ncpu%d: starting xv6\n\n", cpu->id);
801038ed:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801038f3:	0f b6 00             	movzbl (%eax),%eax
801038f6:	0f b6 c0             	movzbl %al,%eax
801038f9:	83 ec 08             	sub    $0x8,%esp
801038fc:	50                   	push   %eax
801038fd:	68 c0 8a 10 80       	push   $0x80108ac0
80103902:	e8 bd ca ff ff       	call   801003c4 <cprintf>
80103907:	83 c4 10             	add    $0x10,%esp
  picinit();       // interrupt controller
8010390a:	e8 86 06 00 00       	call   80103f95 <picinit>
  ioapicinit();    // another interrupt controller
8010390f:	e8 22 f1 ff ff       	call   80102a36 <ioapicinit>
  consoleinit();   // I/O devices & their interrupts
80103914:	e8 31 d2 ff ff       	call   80100b4a <consoleinit>
  uartinit();      // serial port
80103919:	e8 79 34 00 00       	call   80106d97 <uartinit>
  pinit();         // process table
8010391e:	e8 76 0b 00 00       	call   80104499 <pinit>
  tvinit();        // trap vectors
80103923:	e8 5b 2f 00 00       	call   80106883 <tvinit>
  binit();         // buffer cache
80103928:	e8 07 c7 ff ff       	call   80100034 <binit>
  fileinit();      // file table
8010392d:	e8 74 d6 ff ff       	call   80100fa6 <fileinit>
  ideinit();       // disk
80103932:	e8 07 ed ff ff       	call   8010263e <ideinit>
  if(!ismp)
80103937:	a1 40 19 11 80       	mov    0x80111940,%eax
8010393c:	85 c0                	test   %eax,%eax
8010393e:	75 05                	jne    80103945 <main+0x92>
    timerinit();   // uniprocessor timer
80103940:	e8 8e 2e 00 00       	call   801067d3 <timerinit>
  startothers();   // start other processors
80103945:	e8 7f 00 00 00       	call   801039c9 <startothers>
  kinit2(P2V(4*1024*1024), P2V(PHYSTOP)); // must come after startothers()
8010394a:	83 ec 08             	sub    $0x8,%esp
8010394d:	68 00 00 00 8e       	push   $0x8e000000
80103952:	68 00 00 40 80       	push   $0x80400000
80103957:	e8 1e f2 ff ff       	call   80102b7a <kinit2>
8010395c:	83 c4 10             	add    $0x10,%esp
  userinit();      // first user process
8010395f:	e8 57 0c 00 00       	call   801045bb <userinit>
  // Finish setting up this processor in mpmain.
  mpmain();
80103964:	e8 1a 00 00 00       	call   80103983 <mpmain>

80103969 <mpenter>:
}

// Other CPUs jump here from entryother.S.
static void
mpenter(void)
{
80103969:	55                   	push   %ebp
8010396a:	89 e5                	mov    %esp,%ebp
8010396c:	83 ec 08             	sub    $0x8,%esp
  switchkvm(); 
8010396f:	e8 36 47 00 00       	call   801080aa <switchkvm>
  seginit();
80103974:	e8 c2 40 00 00       	call   80107a3b <seginit>
  lapicinit();
80103979:	e8 5d f5 ff ff       	call   80102edb <lapicinit>
  mpmain();
8010397e:	e8 00 00 00 00       	call   80103983 <mpmain>

80103983 <mpmain>:
}

// Common CPU setup code.
static void
mpmain(void)
{
80103983:	55                   	push   %ebp
80103984:	89 e5                	mov    %esp,%ebp
80103986:	83 ec 08             	sub    $0x8,%esp
  cprintf("cpu%d: starting\n", cpu->id);
80103989:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
8010398f:	0f b6 00             	movzbl (%eax),%eax
80103992:	0f b6 c0             	movzbl %al,%eax
80103995:	83 ec 08             	sub    $0x8,%esp
80103998:	50                   	push   %eax
80103999:	68 d7 8a 10 80       	push   $0x80108ad7
8010399e:	e8 21 ca ff ff       	call   801003c4 <cprintf>
801039a3:	83 c4 10             	add    $0x10,%esp
  idtinit();       // load idt register
801039a6:	e8 4e 30 00 00       	call   801069f9 <idtinit>
  xchg(&cpu->started, 1); // tell startothers() we're up
801039ab:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801039b1:	05 a8 00 00 00       	add    $0xa8,%eax
801039b6:	83 ec 08             	sub    $0x8,%esp
801039b9:	6a 01                	push   $0x1
801039bb:	50                   	push   %eax
801039bc:	e8 d8 fe ff ff       	call   80103899 <xchg>
801039c1:	83 c4 10             	add    $0x10,%esp
  scheduler();     // start running processes
801039c4:	e8 b5 11 00 00       	call   80104b7e <scheduler>

801039c9 <startothers>:
pde_t entrypgdir[];  // For entry.S

// Start the non-boot (AP) processors.
static void
startothers(void)
{
801039c9:	55                   	push   %ebp
801039ca:	89 e5                	mov    %esp,%ebp
801039cc:	83 ec 18             	sub    $0x18,%esp
  char *stack;

  // Write entry code to unused memory at 0x7000.
  // The linker has placed the image of entryother.S in
  // _binary_entryother_start.
  code = p2v(0x7000);
801039cf:	68 00 70 00 00       	push   $0x7000
801039d4:	e8 b3 fe ff ff       	call   8010388c <p2v>
801039d9:	83 c4 04             	add    $0x4,%esp
801039dc:	89 45 f0             	mov    %eax,-0x10(%ebp)
  memmove(code, _binary_entryother_start, (uint)_binary_entryother_size);
801039df:	b8 8a 00 00 00       	mov    $0x8a,%eax
801039e4:	83 ec 04             	sub    $0x4,%esp
801039e7:	50                   	push   %eax
801039e8:	68 2c b5 10 80       	push   $0x8010b52c
801039ed:	ff 75 f0             	push   -0x10(%ebp)
801039f0:	e8 ad 19 00 00       	call   801053a2 <memmove>
801039f5:	83 c4 10             	add    $0x10,%esp

  for(c = cpus; c < cpus+ncpu; c++){
801039f8:	c7 45 f4 60 13 11 80 	movl   $0x80111360,-0xc(%ebp)
801039ff:	e9 8e 00 00 00       	jmp    80103a92 <startothers+0xc9>
    if(c == cpus+cpunum())  // We've started already.
80103a04:	e8 ee f5 ff ff       	call   80102ff7 <cpunum>
80103a09:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
80103a0f:	05 60 13 11 80       	add    $0x80111360,%eax
80103a14:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80103a17:	74 71                	je     80103a8a <startothers+0xc1>
      continue;

    // Tell entryother.S what stack to use, where to enter, and what 
    // pgdir to use. We cannot use kpgdir yet, because the AP processor
    // is running in low  memory, so we use entrypgdir for the APs too.
    stack = kalloc();
80103a19:	e8 68 f2 ff ff       	call   80102c86 <kalloc>
80103a1e:	89 45 ec             	mov    %eax,-0x14(%ebp)
    *(void**)(code-4) = stack + KSTACKSIZE;
80103a21:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103a24:	83 e8 04             	sub    $0x4,%eax
80103a27:	8b 55 ec             	mov    -0x14(%ebp),%edx
80103a2a:	81 c2 00 10 00 00    	add    $0x1000,%edx
80103a30:	89 10                	mov    %edx,(%eax)
    *(void**)(code-8) = mpenter;
80103a32:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103a35:	83 e8 08             	sub    $0x8,%eax
80103a38:	c7 00 69 39 10 80    	movl   $0x80103969,(%eax)
    *(int**)(code-12) = (void *) v2p(entrypgdir);
80103a3e:	83 ec 0c             	sub    $0xc,%esp
80103a41:	68 00 a0 10 80       	push   $0x8010a000
80103a46:	e8 34 fe ff ff       	call   8010387f <v2p>
80103a4b:	83 c4 10             	add    $0x10,%esp
80103a4e:	8b 55 f0             	mov    -0x10(%ebp),%edx
80103a51:	83 ea 0c             	sub    $0xc,%edx
80103a54:	89 02                	mov    %eax,(%edx)

    lapicstartap(c->id, v2p(code));
80103a56:	83 ec 0c             	sub    $0xc,%esp
80103a59:	ff 75 f0             	push   -0x10(%ebp)
80103a5c:	e8 1e fe ff ff       	call   8010387f <v2p>
80103a61:	83 c4 10             	add    $0x10,%esp
80103a64:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103a67:	0f b6 12             	movzbl (%edx),%edx
80103a6a:	0f b6 d2             	movzbl %dl,%edx
80103a6d:	83 ec 08             	sub    $0x8,%esp
80103a70:	50                   	push   %eax
80103a71:	52                   	push   %edx
80103a72:	e8 fa f5 ff ff       	call   80103071 <lapicstartap>
80103a77:	83 c4 10             	add    $0x10,%esp

    // wait for cpu to finish mpmain()
    while(c->started == 0)
80103a7a:	90                   	nop
80103a7b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103a7e:	8b 80 a8 00 00 00    	mov    0xa8(%eax),%eax
80103a84:	85 c0                	test   %eax,%eax
80103a86:	74 f3                	je     80103a7b <startothers+0xb2>
80103a88:	eb 01                	jmp    80103a8b <startothers+0xc2>
      continue;
80103a8a:	90                   	nop
  for(c = cpus; c < cpus+ncpu; c++){
80103a8b:	81 45 f4 bc 00 00 00 	addl   $0xbc,-0xc(%ebp)
80103a92:	a1 44 19 11 80       	mov    0x80111944,%eax
80103a97:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
80103a9d:	05 60 13 11 80       	add    $0x80111360,%eax
80103aa2:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80103aa5:	0f 82 59 ff ff ff    	jb     80103a04 <startothers+0x3b>
      ;
  }
}
80103aab:	90                   	nop
80103aac:	90                   	nop
80103aad:	c9                   	leave
80103aae:	c3                   	ret

80103aaf <p2v>:
80103aaf:	55                   	push   %ebp
80103ab0:	89 e5                	mov    %esp,%ebp
80103ab2:	8b 45 08             	mov    0x8(%ebp),%eax
80103ab5:	05 00 00 00 80       	add    $0x80000000,%eax
80103aba:	5d                   	pop    %ebp
80103abb:	c3                   	ret

80103abc <inb>:
{
80103abc:	55                   	push   %ebp
80103abd:	89 e5                	mov    %esp,%ebp
80103abf:	83 ec 14             	sub    $0x14,%esp
80103ac2:	8b 45 08             	mov    0x8(%ebp),%eax
80103ac5:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80103ac9:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80103acd:	89 c2                	mov    %eax,%edx
80103acf:	ec                   	in     (%dx),%al
80103ad0:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80103ad3:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80103ad7:	c9                   	leave
80103ad8:	c3                   	ret

80103ad9 <outb>:
{
80103ad9:	55                   	push   %ebp
80103ada:	89 e5                	mov    %esp,%ebp
80103adc:	83 ec 08             	sub    $0x8,%esp
80103adf:	8b 55 08             	mov    0x8(%ebp),%edx
80103ae2:	8b 45 0c             	mov    0xc(%ebp),%eax
80103ae5:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80103ae9:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80103aec:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80103af0:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80103af4:	ee                   	out    %al,(%dx)
}
80103af5:	90                   	nop
80103af6:	c9                   	leave
80103af7:	c3                   	ret

80103af8 <mpbcpu>:
int ncpu;
uchar ioapicid;

int
mpbcpu(void)
{
80103af8:	55                   	push   %ebp
80103af9:	89 e5                	mov    %esp,%ebp
  return bcpu-cpus;
80103afb:	a1 4c 19 11 80       	mov    0x8011194c,%eax
80103b00:	2d 60 13 11 80       	sub    $0x80111360,%eax
80103b05:	c1 f8 02             	sar    $0x2,%eax
80103b08:	69 c0 cf 46 7d 67    	imul   $0x677d46cf,%eax,%eax
}
80103b0e:	5d                   	pop    %ebp
80103b0f:	c3                   	ret

80103b10 <sum>:

static uchar
sum(uchar *addr, int len)
{
80103b10:	55                   	push   %ebp
80103b11:	89 e5                	mov    %esp,%ebp
80103b13:	83 ec 10             	sub    $0x10,%esp
  int i, sum;
  
  sum = 0;
80103b16:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
  for(i=0; i<len; i++)
80103b1d:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80103b24:	eb 15                	jmp    80103b3b <sum+0x2b>
    sum += addr[i];
80103b26:	8b 55 fc             	mov    -0x4(%ebp),%edx
80103b29:	8b 45 08             	mov    0x8(%ebp),%eax
80103b2c:	01 d0                	add    %edx,%eax
80103b2e:	0f b6 00             	movzbl (%eax),%eax
80103b31:	0f b6 c0             	movzbl %al,%eax
80103b34:	01 45 f8             	add    %eax,-0x8(%ebp)
  for(i=0; i<len; i++)
80103b37:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80103b3b:	8b 45 fc             	mov    -0x4(%ebp),%eax
80103b3e:	3b 45 0c             	cmp    0xc(%ebp),%eax
80103b41:	7c e3                	jl     80103b26 <sum+0x16>
  return sum;
80103b43:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
80103b46:	c9                   	leave
80103b47:	c3                   	ret

80103b48 <mpsearch1>:

// Look for an MP structure in the len bytes at addr.
static struct mp*
mpsearch1(uint a, int len)
{
80103b48:	55                   	push   %ebp
80103b49:	89 e5                	mov    %esp,%ebp
80103b4b:	83 ec 18             	sub    $0x18,%esp
  uchar *e, *p, *addr;

  addr = p2v(a);
80103b4e:	ff 75 08             	push   0x8(%ebp)
80103b51:	e8 59 ff ff ff       	call   80103aaf <p2v>
80103b56:	83 c4 04             	add    $0x4,%esp
80103b59:	89 45 f0             	mov    %eax,-0x10(%ebp)
  e = addr+len;
80103b5c:	8b 55 0c             	mov    0xc(%ebp),%edx
80103b5f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103b62:	01 d0                	add    %edx,%eax
80103b64:	89 45 ec             	mov    %eax,-0x14(%ebp)
  for(p = addr; p < e; p += sizeof(struct mp))
80103b67:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103b6a:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103b6d:	eb 36                	jmp    80103ba5 <mpsearch1+0x5d>
    if(memcmp(p, "_MP_", 4) == 0 && sum(p, sizeof(struct mp)) == 0)
80103b6f:	83 ec 04             	sub    $0x4,%esp
80103b72:	6a 04                	push   $0x4
80103b74:	68 e8 8a 10 80       	push   $0x80108ae8
80103b79:	ff 75 f4             	push   -0xc(%ebp)
80103b7c:	e8 c9 17 00 00       	call   8010534a <memcmp>
80103b81:	83 c4 10             	add    $0x10,%esp
80103b84:	85 c0                	test   %eax,%eax
80103b86:	75 19                	jne    80103ba1 <mpsearch1+0x59>
80103b88:	83 ec 08             	sub    $0x8,%esp
80103b8b:	6a 10                	push   $0x10
80103b8d:	ff 75 f4             	push   -0xc(%ebp)
80103b90:	e8 7b ff ff ff       	call   80103b10 <sum>
80103b95:	83 c4 10             	add    $0x10,%esp
80103b98:	84 c0                	test   %al,%al
80103b9a:	75 05                	jne    80103ba1 <mpsearch1+0x59>
      return (struct mp*)p;
80103b9c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b9f:	eb 11                	jmp    80103bb2 <mpsearch1+0x6a>
  for(p = addr; p < e; p += sizeof(struct mp))
80103ba1:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
80103ba5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103ba8:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80103bab:	72 c2                	jb     80103b6f <mpsearch1+0x27>
  return 0;
80103bad:	b8 00 00 00 00       	mov    $0x0,%eax
}
80103bb2:	c9                   	leave
80103bb3:	c3                   	ret

80103bb4 <mpsearch>:
// 1) in the first KB of the EBDA;
// 2) in the last KB of system base memory;
// 3) in the BIOS ROM between 0xE0000 and 0xFFFFF.
static struct mp*
mpsearch(void)
{
80103bb4:	55                   	push   %ebp
80103bb5:	89 e5                	mov    %esp,%ebp
80103bb7:	83 ec 18             	sub    $0x18,%esp
  uchar *bda;
  uint p;
  struct mp *mp;

  bda = (uchar *) P2V(0x400);
80103bba:	c7 45 f4 00 04 00 80 	movl   $0x80000400,-0xc(%ebp)
  if((p = ((bda[0x0F]<<8)| bda[0x0E]) << 4)){
80103bc1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103bc4:	83 c0 0f             	add    $0xf,%eax
80103bc7:	0f b6 00             	movzbl (%eax),%eax
80103bca:	0f b6 c0             	movzbl %al,%eax
80103bcd:	c1 e0 08             	shl    $0x8,%eax
80103bd0:	89 c2                	mov    %eax,%edx
80103bd2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103bd5:	83 c0 0e             	add    $0xe,%eax
80103bd8:	0f b6 00             	movzbl (%eax),%eax
80103bdb:	0f b6 c0             	movzbl %al,%eax
80103bde:	09 d0                	or     %edx,%eax
80103be0:	c1 e0 04             	shl    $0x4,%eax
80103be3:	89 45 f0             	mov    %eax,-0x10(%ebp)
80103be6:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80103bea:	74 21                	je     80103c0d <mpsearch+0x59>
    if((mp = mpsearch1(p, 1024)))
80103bec:	83 ec 08             	sub    $0x8,%esp
80103bef:	68 00 04 00 00       	push   $0x400
80103bf4:	ff 75 f0             	push   -0x10(%ebp)
80103bf7:	e8 4c ff ff ff       	call   80103b48 <mpsearch1>
80103bfc:	83 c4 10             	add    $0x10,%esp
80103bff:	89 45 ec             	mov    %eax,-0x14(%ebp)
80103c02:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80103c06:	74 51                	je     80103c59 <mpsearch+0xa5>
      return mp;
80103c08:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103c0b:	eb 61                	jmp    80103c6e <mpsearch+0xba>
  } else {
    p = ((bda[0x14]<<8)|bda[0x13])*1024;
80103c0d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c10:	83 c0 14             	add    $0x14,%eax
80103c13:	0f b6 00             	movzbl (%eax),%eax
80103c16:	0f b6 c0             	movzbl %al,%eax
80103c19:	c1 e0 08             	shl    $0x8,%eax
80103c1c:	89 c2                	mov    %eax,%edx
80103c1e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c21:	83 c0 13             	add    $0x13,%eax
80103c24:	0f b6 00             	movzbl (%eax),%eax
80103c27:	0f b6 c0             	movzbl %al,%eax
80103c2a:	09 d0                	or     %edx,%eax
80103c2c:	c1 e0 0a             	shl    $0xa,%eax
80103c2f:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if((mp = mpsearch1(p-1024, 1024)))
80103c32:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103c35:	2d 00 04 00 00       	sub    $0x400,%eax
80103c3a:	83 ec 08             	sub    $0x8,%esp
80103c3d:	68 00 04 00 00       	push   $0x400
80103c42:	50                   	push   %eax
80103c43:	e8 00 ff ff ff       	call   80103b48 <mpsearch1>
80103c48:	83 c4 10             	add    $0x10,%esp
80103c4b:	89 45 ec             	mov    %eax,-0x14(%ebp)
80103c4e:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80103c52:	74 05                	je     80103c59 <mpsearch+0xa5>
      return mp;
80103c54:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103c57:	eb 15                	jmp    80103c6e <mpsearch+0xba>
  }
  return mpsearch1(0xF0000, 0x10000);
80103c59:	83 ec 08             	sub    $0x8,%esp
80103c5c:	68 00 00 01 00       	push   $0x10000
80103c61:	68 00 00 0f 00       	push   $0xf0000
80103c66:	e8 dd fe ff ff       	call   80103b48 <mpsearch1>
80103c6b:	83 c4 10             	add    $0x10,%esp
}
80103c6e:	c9                   	leave
80103c6f:	c3                   	ret

80103c70 <mpconfig>:
// Check for correct signature, calculate the checksum and,
// if correct, check the version.
// To do: check extended table checksum.
static struct mpconf*
mpconfig(struct mp **pmp)
{
80103c70:	55                   	push   %ebp
80103c71:	89 e5                	mov    %esp,%ebp
80103c73:	83 ec 18             	sub    $0x18,%esp
  struct mpconf *conf;
  struct mp *mp;

  if((mp = mpsearch()) == 0 || mp->physaddr == 0)
80103c76:	e8 39 ff ff ff       	call   80103bb4 <mpsearch>
80103c7b:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103c7e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103c82:	74 0a                	je     80103c8e <mpconfig+0x1e>
80103c84:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c87:	8b 40 04             	mov    0x4(%eax),%eax
80103c8a:	85 c0                	test   %eax,%eax
80103c8c:	75 0a                	jne    80103c98 <mpconfig+0x28>
    return 0;
80103c8e:	b8 00 00 00 00       	mov    $0x0,%eax
80103c93:	e9 81 00 00 00       	jmp    80103d19 <mpconfig+0xa9>
  conf = (struct mpconf*) p2v((uint) mp->physaddr);
80103c98:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c9b:	8b 40 04             	mov    0x4(%eax),%eax
80103c9e:	83 ec 0c             	sub    $0xc,%esp
80103ca1:	50                   	push   %eax
80103ca2:	e8 08 fe ff ff       	call   80103aaf <p2v>
80103ca7:	83 c4 10             	add    $0x10,%esp
80103caa:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(memcmp(conf, "PCMP", 4) != 0)
80103cad:	83 ec 04             	sub    $0x4,%esp
80103cb0:	6a 04                	push   $0x4
80103cb2:	68 ed 8a 10 80       	push   $0x80108aed
80103cb7:	ff 75 f0             	push   -0x10(%ebp)
80103cba:	e8 8b 16 00 00       	call   8010534a <memcmp>
80103cbf:	83 c4 10             	add    $0x10,%esp
80103cc2:	85 c0                	test   %eax,%eax
80103cc4:	74 07                	je     80103ccd <mpconfig+0x5d>
    return 0;
80103cc6:	b8 00 00 00 00       	mov    $0x0,%eax
80103ccb:	eb 4c                	jmp    80103d19 <mpconfig+0xa9>
  if(conf->version != 1 && conf->version != 4)
80103ccd:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103cd0:	0f b6 40 06          	movzbl 0x6(%eax),%eax
80103cd4:	3c 01                	cmp    $0x1,%al
80103cd6:	74 12                	je     80103cea <mpconfig+0x7a>
80103cd8:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103cdb:	0f b6 40 06          	movzbl 0x6(%eax),%eax
80103cdf:	3c 04                	cmp    $0x4,%al
80103ce1:	74 07                	je     80103cea <mpconfig+0x7a>
    return 0;
80103ce3:	b8 00 00 00 00       	mov    $0x0,%eax
80103ce8:	eb 2f                	jmp    80103d19 <mpconfig+0xa9>
  if(sum((uchar*)conf, conf->length) != 0)
80103cea:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103ced:	0f b7 40 04          	movzwl 0x4(%eax),%eax
80103cf1:	0f b7 c0             	movzwl %ax,%eax
80103cf4:	83 ec 08             	sub    $0x8,%esp
80103cf7:	50                   	push   %eax
80103cf8:	ff 75 f0             	push   -0x10(%ebp)
80103cfb:	e8 10 fe ff ff       	call   80103b10 <sum>
80103d00:	83 c4 10             	add    $0x10,%esp
80103d03:	84 c0                	test   %al,%al
80103d05:	74 07                	je     80103d0e <mpconfig+0x9e>
    return 0;
80103d07:	b8 00 00 00 00       	mov    $0x0,%eax
80103d0c:	eb 0b                	jmp    80103d19 <mpconfig+0xa9>
  *pmp = mp;
80103d0e:	8b 45 08             	mov    0x8(%ebp),%eax
80103d11:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103d14:	89 10                	mov    %edx,(%eax)
  return conf;
80103d16:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80103d19:	c9                   	leave
80103d1a:	c3                   	ret

80103d1b <mpinit>:

void
mpinit(void)
{
80103d1b:	55                   	push   %ebp
80103d1c:	89 e5                	mov    %esp,%ebp
80103d1e:	83 ec 28             	sub    $0x28,%esp
  struct mp *mp;
  struct mpconf *conf;
  struct mpproc *proc;
  struct mpioapic *ioapic;

  bcpu = &cpus[0];
80103d21:	c7 05 4c 19 11 80 60 	movl   $0x80111360,0x8011194c
80103d28:	13 11 80 
  if((conf = mpconfig(&mp)) == 0)
80103d2b:	83 ec 0c             	sub    $0xc,%esp
80103d2e:	8d 45 e0             	lea    -0x20(%ebp),%eax
80103d31:	50                   	push   %eax
80103d32:	e8 39 ff ff ff       	call   80103c70 <mpconfig>
80103d37:	83 c4 10             	add    $0x10,%esp
80103d3a:	89 45 f0             	mov    %eax,-0x10(%ebp)
80103d3d:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80103d41:	0f 84 ba 01 00 00    	je     80103f01 <mpinit+0x1e6>
    return;
  ismp = 1;
80103d47:	c7 05 40 19 11 80 01 	movl   $0x1,0x80111940
80103d4e:	00 00 00 
  lapic = (uint*)conf->lapicaddr;
80103d51:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103d54:	8b 40 24             	mov    0x24(%eax),%eax
80103d57:	a3 60 12 11 80       	mov    %eax,0x80111260
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
80103d5c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103d5f:	83 c0 2c             	add    $0x2c,%eax
80103d62:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103d65:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103d68:	0f b7 40 04          	movzwl 0x4(%eax),%eax
80103d6c:	0f b7 d0             	movzwl %ax,%edx
80103d6f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103d72:	01 d0                	add    %edx,%eax
80103d74:	89 45 ec             	mov    %eax,-0x14(%ebp)
80103d77:	e9 16 01 00 00       	jmp    80103e92 <mpinit+0x177>
    switch(*p){
80103d7c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103d7f:	0f b6 00             	movzbl (%eax),%eax
80103d82:	0f b6 c0             	movzbl %al,%eax
80103d85:	83 f8 04             	cmp    $0x4,%eax
80103d88:	0f 8f e0 00 00 00    	jg     80103e6e <mpinit+0x153>
80103d8e:	83 f8 03             	cmp    $0x3,%eax
80103d91:	0f 8d d1 00 00 00    	jge    80103e68 <mpinit+0x14d>
80103d97:	83 f8 02             	cmp    $0x2,%eax
80103d9a:	0f 84 b0 00 00 00    	je     80103e50 <mpinit+0x135>
80103da0:	83 f8 02             	cmp    $0x2,%eax
80103da3:	0f 8f c5 00 00 00    	jg     80103e6e <mpinit+0x153>
80103da9:	85 c0                	test   %eax,%eax
80103dab:	74 0e                	je     80103dbb <mpinit+0xa0>
80103dad:	83 f8 01             	cmp    $0x1,%eax
80103db0:	0f 84 b2 00 00 00    	je     80103e68 <mpinit+0x14d>
80103db6:	e9 b3 00 00 00       	jmp    80103e6e <mpinit+0x153>
    case MPPROC:
      proc = (struct mpproc*)p;
80103dbb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103dbe:	89 45 e4             	mov    %eax,-0x1c(%ebp)
      if(ncpu != proc->apicid){
80103dc1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80103dc4:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80103dc8:	0f b6 d0             	movzbl %al,%edx
80103dcb:	a1 44 19 11 80       	mov    0x80111944,%eax
80103dd0:	39 c2                	cmp    %eax,%edx
80103dd2:	74 2b                	je     80103dff <mpinit+0xe4>
        cprintf("mpinit: ncpu=%d apicid=%d\n", ncpu, proc->apicid);
80103dd4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80103dd7:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80103ddb:	0f b6 d0             	movzbl %al,%edx
80103dde:	a1 44 19 11 80       	mov    0x80111944,%eax
80103de3:	83 ec 04             	sub    $0x4,%esp
80103de6:	52                   	push   %edx
80103de7:	50                   	push   %eax
80103de8:	68 f2 8a 10 80       	push   $0x80108af2
80103ded:	e8 d2 c5 ff ff       	call   801003c4 <cprintf>
80103df2:	83 c4 10             	add    $0x10,%esp
        ismp = 0;
80103df5:	c7 05 40 19 11 80 00 	movl   $0x0,0x80111940
80103dfc:	00 00 00 
      }
      if(proc->flags & MPBOOT)
80103dff:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80103e02:	0f b6 40 03          	movzbl 0x3(%eax),%eax
80103e06:	0f b6 c0             	movzbl %al,%eax
80103e09:	83 e0 02             	and    $0x2,%eax
80103e0c:	85 c0                	test   %eax,%eax
80103e0e:	74 15                	je     80103e25 <mpinit+0x10a>
        bcpu = &cpus[ncpu];
80103e10:	a1 44 19 11 80       	mov    0x80111944,%eax
80103e15:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
80103e1b:	05 60 13 11 80       	add    $0x80111360,%eax
80103e20:	a3 4c 19 11 80       	mov    %eax,0x8011194c
      cpus[ncpu].id = ncpu;
80103e25:	8b 15 44 19 11 80    	mov    0x80111944,%edx
80103e2b:	a1 44 19 11 80       	mov    0x80111944,%eax
80103e30:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
80103e36:	05 60 13 11 80       	add    $0x80111360,%eax
80103e3b:	88 10                	mov    %dl,(%eax)
      ncpu++;
80103e3d:	a1 44 19 11 80       	mov    0x80111944,%eax
80103e42:	83 c0 01             	add    $0x1,%eax
80103e45:	a3 44 19 11 80       	mov    %eax,0x80111944
      p += sizeof(struct mpproc);
80103e4a:	83 45 f4 14          	addl   $0x14,-0xc(%ebp)
      continue;
80103e4e:	eb 42                	jmp    80103e92 <mpinit+0x177>
    case MPIOAPIC:
      ioapic = (struct mpioapic*)p;
80103e50:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103e53:	89 45 e8             	mov    %eax,-0x18(%ebp)
      ioapicid = ioapic->apicno;
80103e56:	8b 45 e8             	mov    -0x18(%ebp),%eax
80103e59:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80103e5d:	a2 48 19 11 80       	mov    %al,0x80111948
      p += sizeof(struct mpioapic);
80103e62:	83 45 f4 08          	addl   $0x8,-0xc(%ebp)
      continue;
80103e66:	eb 2a                	jmp    80103e92 <mpinit+0x177>
    case MPBUS:
    case MPIOINTR:
    case MPLINTR:
      p += 8;
80103e68:	83 45 f4 08          	addl   $0x8,-0xc(%ebp)
      continue;
80103e6c:	eb 24                	jmp    80103e92 <mpinit+0x177>
    default:
      cprintf("mpinit: unknown config type %x\n", *p);
80103e6e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103e71:	0f b6 00             	movzbl (%eax),%eax
80103e74:	0f b6 c0             	movzbl %al,%eax
80103e77:	83 ec 08             	sub    $0x8,%esp
80103e7a:	50                   	push   %eax
80103e7b:	68 10 8b 10 80       	push   $0x80108b10
80103e80:	e8 3f c5 ff ff       	call   801003c4 <cprintf>
80103e85:	83 c4 10             	add    $0x10,%esp
      ismp = 0;
80103e88:	c7 05 40 19 11 80 00 	movl   $0x0,0x80111940
80103e8f:	00 00 00 
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
80103e92:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103e95:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80103e98:	0f 82 de fe ff ff    	jb     80103d7c <mpinit+0x61>
    }
  }
  if(!ismp){
80103e9e:	a1 40 19 11 80       	mov    0x80111940,%eax
80103ea3:	85 c0                	test   %eax,%eax
80103ea5:	75 1d                	jne    80103ec4 <mpinit+0x1a9>
    // Didn't like what we found; fall back to no MP.
    ncpu = 1;
80103ea7:	c7 05 44 19 11 80 01 	movl   $0x1,0x80111944
80103eae:	00 00 00 
    lapic = 0;
80103eb1:	c7 05 60 12 11 80 00 	movl   $0x0,0x80111260
80103eb8:	00 00 00 
    ioapicid = 0;
80103ebb:	c6 05 48 19 11 80 00 	movb   $0x0,0x80111948
    return;
80103ec2:	eb 3e                	jmp    80103f02 <mpinit+0x1e7>
  }

  if(mp->imcrp){
80103ec4:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103ec7:	0f b6 40 0c          	movzbl 0xc(%eax),%eax
80103ecb:	84 c0                	test   %al,%al
80103ecd:	74 33                	je     80103f02 <mpinit+0x1e7>
    // Bochs doesn't support IMCR, so this doesn't run on Bochs.
    // But it would on real hardware.
    outb(0x22, 0x70);   // Select IMCR
80103ecf:	83 ec 08             	sub    $0x8,%esp
80103ed2:	6a 70                	push   $0x70
80103ed4:	6a 22                	push   $0x22
80103ed6:	e8 fe fb ff ff       	call   80103ad9 <outb>
80103edb:	83 c4 10             	add    $0x10,%esp
    outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
80103ede:	83 ec 0c             	sub    $0xc,%esp
80103ee1:	6a 23                	push   $0x23
80103ee3:	e8 d4 fb ff ff       	call   80103abc <inb>
80103ee8:	83 c4 10             	add    $0x10,%esp
80103eeb:	83 c8 01             	or     $0x1,%eax
80103eee:	0f b6 c0             	movzbl %al,%eax
80103ef1:	83 ec 08             	sub    $0x8,%esp
80103ef4:	50                   	push   %eax
80103ef5:	6a 23                	push   $0x23
80103ef7:	e8 dd fb ff ff       	call   80103ad9 <outb>
80103efc:	83 c4 10             	add    $0x10,%esp
80103eff:	eb 01                	jmp    80103f02 <mpinit+0x1e7>
    return;
80103f01:	90                   	nop
  }
}
80103f02:	c9                   	leave
80103f03:	c3                   	ret

80103f04 <outb>:
{
80103f04:	55                   	push   %ebp
80103f05:	89 e5                	mov    %esp,%ebp
80103f07:	83 ec 08             	sub    $0x8,%esp
80103f0a:	8b 55 08             	mov    0x8(%ebp),%edx
80103f0d:	8b 45 0c             	mov    0xc(%ebp),%eax
80103f10:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80103f14:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80103f17:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80103f1b:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80103f1f:	ee                   	out    %al,(%dx)
}
80103f20:	90                   	nop
80103f21:	c9                   	leave
80103f22:	c3                   	ret

80103f23 <picsetmask>:
// Initial IRQ mask has interrupt 2 enabled (for slave 8259A).
static ushort irqmask = 0xFFFF & ~(1<<IRQ_SLAVE);

static void
picsetmask(ushort mask)
{
80103f23:	55                   	push   %ebp
80103f24:	89 e5                	mov    %esp,%ebp
80103f26:	83 ec 04             	sub    $0x4,%esp
80103f29:	8b 45 08             	mov    0x8(%ebp),%eax
80103f2c:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  irqmask = mask;
80103f30:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80103f34:	66 a3 00 b0 10 80    	mov    %ax,0x8010b000
  outb(IO_PIC1+1, mask);
80103f3a:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80103f3e:	0f b6 c0             	movzbl %al,%eax
80103f41:	50                   	push   %eax
80103f42:	6a 21                	push   $0x21
80103f44:	e8 bb ff ff ff       	call   80103f04 <outb>
80103f49:	83 c4 08             	add    $0x8,%esp
  outb(IO_PIC2+1, mask >> 8);
80103f4c:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80103f50:	66 c1 e8 08          	shr    $0x8,%ax
80103f54:	0f b6 c0             	movzbl %al,%eax
80103f57:	50                   	push   %eax
80103f58:	68 a1 00 00 00       	push   $0xa1
80103f5d:	e8 a2 ff ff ff       	call   80103f04 <outb>
80103f62:	83 c4 08             	add    $0x8,%esp
}
80103f65:	90                   	nop
80103f66:	c9                   	leave
80103f67:	c3                   	ret

80103f68 <picenable>:

void
picenable(int irq)
{
80103f68:	55                   	push   %ebp
80103f69:	89 e5                	mov    %esp,%ebp
  picsetmask(irqmask & ~(1<<irq));
80103f6b:	8b 45 08             	mov    0x8(%ebp),%eax
80103f6e:	ba 01 00 00 00       	mov    $0x1,%edx
80103f73:	89 c1                	mov    %eax,%ecx
80103f75:	d3 e2                	shl    %cl,%edx
80103f77:	89 d0                	mov    %edx,%eax
80103f79:	f7 d0                	not    %eax
80103f7b:	89 c2                	mov    %eax,%edx
80103f7d:	0f b7 05 00 b0 10 80 	movzwl 0x8010b000,%eax
80103f84:	21 d0                	and    %edx,%eax
80103f86:	0f b7 c0             	movzwl %ax,%eax
80103f89:	50                   	push   %eax
80103f8a:	e8 94 ff ff ff       	call   80103f23 <picsetmask>
80103f8f:	83 c4 04             	add    $0x4,%esp
}
80103f92:	90                   	nop
80103f93:	c9                   	leave
80103f94:	c3                   	ret

80103f95 <picinit>:

// Initialize the 8259A interrupt controllers.
void
picinit(void)
{
80103f95:	55                   	push   %ebp
80103f96:	89 e5                	mov    %esp,%ebp
  // mask all interrupts
  outb(IO_PIC1+1, 0xFF);
80103f98:	68 ff 00 00 00       	push   $0xff
80103f9d:	6a 21                	push   $0x21
80103f9f:	e8 60 ff ff ff       	call   80103f04 <outb>
80103fa4:	83 c4 08             	add    $0x8,%esp
  outb(IO_PIC2+1, 0xFF);
80103fa7:	68 ff 00 00 00       	push   $0xff
80103fac:	68 a1 00 00 00       	push   $0xa1
80103fb1:	e8 4e ff ff ff       	call   80103f04 <outb>
80103fb6:	83 c4 08             	add    $0x8,%esp

  // ICW1:  0001g0hi
  //    g:  0 = edge triggering, 1 = level triggering
  //    h:  0 = cascaded PICs, 1 = master only
  //    i:  0 = no ICW4, 1 = ICW4 required
  outb(IO_PIC1, 0x11);
80103fb9:	6a 11                	push   $0x11
80103fbb:	6a 20                	push   $0x20
80103fbd:	e8 42 ff ff ff       	call   80103f04 <outb>
80103fc2:	83 c4 08             	add    $0x8,%esp

  // ICW2:  Vector offset
  outb(IO_PIC1+1, T_IRQ0);
80103fc5:	6a 20                	push   $0x20
80103fc7:	6a 21                	push   $0x21
80103fc9:	e8 36 ff ff ff       	call   80103f04 <outb>
80103fce:	83 c4 08             	add    $0x8,%esp

  // ICW3:  (master PIC) bit mask of IR lines connected to slaves
  //        (slave PIC) 3-bit # of slave's connection to master
  outb(IO_PIC1+1, 1<<IRQ_SLAVE);
80103fd1:	6a 04                	push   $0x4
80103fd3:	6a 21                	push   $0x21
80103fd5:	e8 2a ff ff ff       	call   80103f04 <outb>
80103fda:	83 c4 08             	add    $0x8,%esp
  //    m:  0 = slave PIC, 1 = master PIC
  //      (ignored when b is 0, as the master/slave role
  //      can be hardwired).
  //    a:  1 = Automatic EOI mode
  //    p:  0 = MCS-80/85 mode, 1 = intel x86 mode
  outb(IO_PIC1+1, 0x3);
80103fdd:	6a 03                	push   $0x3
80103fdf:	6a 21                	push   $0x21
80103fe1:	e8 1e ff ff ff       	call   80103f04 <outb>
80103fe6:	83 c4 08             	add    $0x8,%esp

  // Set up slave (8259A-2)
  outb(IO_PIC2, 0x11);                  // ICW1
80103fe9:	6a 11                	push   $0x11
80103feb:	68 a0 00 00 00       	push   $0xa0
80103ff0:	e8 0f ff ff ff       	call   80103f04 <outb>
80103ff5:	83 c4 08             	add    $0x8,%esp
  outb(IO_PIC2+1, T_IRQ0 + 8);      // ICW2
80103ff8:	6a 28                	push   $0x28
80103ffa:	68 a1 00 00 00       	push   $0xa1
80103fff:	e8 00 ff ff ff       	call   80103f04 <outb>
80104004:	83 c4 08             	add    $0x8,%esp
  outb(IO_PIC2+1, IRQ_SLAVE);           // ICW3
80104007:	6a 02                	push   $0x2
80104009:	68 a1 00 00 00       	push   $0xa1
8010400e:	e8 f1 fe ff ff       	call   80103f04 <outb>
80104013:	83 c4 08             	add    $0x8,%esp
  // NB Automatic EOI mode doesn't tend to work on the slave.
  // Linux source code says it's "to be investigated".
  outb(IO_PIC2+1, 0x3);                 // ICW4
80104016:	6a 03                	push   $0x3
80104018:	68 a1 00 00 00       	push   $0xa1
8010401d:	e8 e2 fe ff ff       	call   80103f04 <outb>
80104022:	83 c4 08             	add    $0x8,%esp

  // OCW3:  0ef01prs
  //   ef:  0x = NOP, 10 = clear specific mask, 11 = set specific mask
  //    p:  0 = no polling, 1 = polling mode
  //   rs:  0x = NOP, 10 = read IRR, 11 = read ISR
  outb(IO_PIC1, 0x68);             // clear specific mask
80104025:	6a 68                	push   $0x68
80104027:	6a 20                	push   $0x20
80104029:	e8 d6 fe ff ff       	call   80103f04 <outb>
8010402e:	83 c4 08             	add    $0x8,%esp
  outb(IO_PIC1, 0x0a);             // read IRR by default
80104031:	6a 0a                	push   $0xa
80104033:	6a 20                	push   $0x20
80104035:	e8 ca fe ff ff       	call   80103f04 <outb>
8010403a:	83 c4 08             	add    $0x8,%esp

  outb(IO_PIC2, 0x68);             // OCW3
8010403d:	6a 68                	push   $0x68
8010403f:	68 a0 00 00 00       	push   $0xa0
80104044:	e8 bb fe ff ff       	call   80103f04 <outb>
80104049:	83 c4 08             	add    $0x8,%esp
  outb(IO_PIC2, 0x0a);             // OCW3
8010404c:	6a 0a                	push   $0xa
8010404e:	68 a0 00 00 00       	push   $0xa0
80104053:	e8 ac fe ff ff       	call   80103f04 <outb>
80104058:	83 c4 08             	add    $0x8,%esp

  if(irqmask != 0xFFFF)
8010405b:	0f b7 05 00 b0 10 80 	movzwl 0x8010b000,%eax
80104062:	66 83 f8 ff          	cmp    $0xffff,%ax
80104066:	74 13                	je     8010407b <picinit+0xe6>
    picsetmask(irqmask);
80104068:	0f b7 05 00 b0 10 80 	movzwl 0x8010b000,%eax
8010406f:	0f b7 c0             	movzwl %ax,%eax
80104072:	50                   	push   %eax
80104073:	e8 ab fe ff ff       	call   80103f23 <picsetmask>
80104078:	83 c4 04             	add    $0x4,%esp
}
8010407b:	90                   	nop
8010407c:	c9                   	leave
8010407d:	c3                   	ret

8010407e <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
8010407e:	55                   	push   %ebp
8010407f:	89 e5                	mov    %esp,%ebp
80104081:	83 ec 18             	sub    $0x18,%esp
  struct pipe *p;

  p = 0;
80104084:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  *f0 = *f1 = 0;
8010408b:	8b 45 0c             	mov    0xc(%ebp),%eax
8010408e:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
80104094:	8b 45 0c             	mov    0xc(%ebp),%eax
80104097:	8b 10                	mov    (%eax),%edx
80104099:	8b 45 08             	mov    0x8(%ebp),%eax
8010409c:	89 10                	mov    %edx,(%eax)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
8010409e:	e8 21 cf ff ff       	call   80100fc4 <filealloc>
801040a3:	8b 55 08             	mov    0x8(%ebp),%edx
801040a6:	89 02                	mov    %eax,(%edx)
801040a8:	8b 45 08             	mov    0x8(%ebp),%eax
801040ab:	8b 00                	mov    (%eax),%eax
801040ad:	85 c0                	test   %eax,%eax
801040af:	0f 84 c8 00 00 00    	je     8010417d <pipealloc+0xff>
801040b5:	e8 0a cf ff ff       	call   80100fc4 <filealloc>
801040ba:	8b 55 0c             	mov    0xc(%ebp),%edx
801040bd:	89 02                	mov    %eax,(%edx)
801040bf:	8b 45 0c             	mov    0xc(%ebp),%eax
801040c2:	8b 00                	mov    (%eax),%eax
801040c4:	85 c0                	test   %eax,%eax
801040c6:	0f 84 b1 00 00 00    	je     8010417d <pipealloc+0xff>
    goto bad;
  if((p = (struct pipe*)kalloc()) == 0)
801040cc:	e8 b5 eb ff ff       	call   80102c86 <kalloc>
801040d1:	89 45 f4             	mov    %eax,-0xc(%ebp)
801040d4:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801040d8:	0f 84 a2 00 00 00    	je     80104180 <pipealloc+0x102>
    goto bad;
  p->readopen = 1;
801040de:	8b 45 f4             	mov    -0xc(%ebp),%eax
801040e1:	c7 80 3c 02 00 00 01 	movl   $0x1,0x23c(%eax)
801040e8:	00 00 00 
  p->writeopen = 1;
801040eb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801040ee:	c7 80 40 02 00 00 01 	movl   $0x1,0x240(%eax)
801040f5:	00 00 00 
  p->nwrite = 0;
801040f8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801040fb:	c7 80 38 02 00 00 00 	movl   $0x0,0x238(%eax)
80104102:	00 00 00 
  p->nread = 0;
80104105:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104108:	c7 80 34 02 00 00 00 	movl   $0x0,0x234(%eax)
8010410f:	00 00 00 
  initlock(&p->lock, "pipe");
80104112:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104115:	83 ec 08             	sub    $0x8,%esp
80104118:	68 30 8b 10 80       	push   $0x80108b30
8010411d:	50                   	push   %eax
8010411e:	e8 3a 0f 00 00       	call   8010505d <initlock>
80104123:	83 c4 10             	add    $0x10,%esp
  (*f0)->type = FD_PIPE;
80104126:	8b 45 08             	mov    0x8(%ebp),%eax
80104129:	8b 00                	mov    (%eax),%eax
8010412b:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f0)->readable = 1;
80104131:	8b 45 08             	mov    0x8(%ebp),%eax
80104134:	8b 00                	mov    (%eax),%eax
80104136:	c6 40 08 01          	movb   $0x1,0x8(%eax)
  (*f0)->writable = 0;
8010413a:	8b 45 08             	mov    0x8(%ebp),%eax
8010413d:	8b 00                	mov    (%eax),%eax
8010413f:	c6 40 09 00          	movb   $0x0,0x9(%eax)
  (*f0)->pipe = p;
80104143:	8b 45 08             	mov    0x8(%ebp),%eax
80104146:	8b 00                	mov    (%eax),%eax
80104148:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010414b:	89 50 0c             	mov    %edx,0xc(%eax)
  (*f1)->type = FD_PIPE;
8010414e:	8b 45 0c             	mov    0xc(%ebp),%eax
80104151:	8b 00                	mov    (%eax),%eax
80104153:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f1)->readable = 0;
80104159:	8b 45 0c             	mov    0xc(%ebp),%eax
8010415c:	8b 00                	mov    (%eax),%eax
8010415e:	c6 40 08 00          	movb   $0x0,0x8(%eax)
  (*f1)->writable = 1;
80104162:	8b 45 0c             	mov    0xc(%ebp),%eax
80104165:	8b 00                	mov    (%eax),%eax
80104167:	c6 40 09 01          	movb   $0x1,0x9(%eax)
  (*f1)->pipe = p;
8010416b:	8b 45 0c             	mov    0xc(%ebp),%eax
8010416e:	8b 00                	mov    (%eax),%eax
80104170:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104173:	89 50 0c             	mov    %edx,0xc(%eax)
  return 0;
80104176:	b8 00 00 00 00       	mov    $0x0,%eax
8010417b:	eb 51                	jmp    801041ce <pipealloc+0x150>
    goto bad;
8010417d:	90                   	nop
8010417e:	eb 01                	jmp    80104181 <pipealloc+0x103>
    goto bad;
80104180:	90                   	nop

//PAGEBREAK: 20
 bad:
  if(p)
80104181:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80104185:	74 0e                	je     80104195 <pipealloc+0x117>
    kfree((char*)p);
80104187:	83 ec 0c             	sub    $0xc,%esp
8010418a:	ff 75 f4             	push   -0xc(%ebp)
8010418d:	e8 4a ea ff ff       	call   80102bdc <kfree>
80104192:	83 c4 10             	add    $0x10,%esp
  if(*f0)
80104195:	8b 45 08             	mov    0x8(%ebp),%eax
80104198:	8b 00                	mov    (%eax),%eax
8010419a:	85 c0                	test   %eax,%eax
8010419c:	74 11                	je     801041af <pipealloc+0x131>
    fileclose(*f0);
8010419e:	8b 45 08             	mov    0x8(%ebp),%eax
801041a1:	8b 00                	mov    (%eax),%eax
801041a3:	83 ec 0c             	sub    $0xc,%esp
801041a6:	50                   	push   %eax
801041a7:	e8 d6 ce ff ff       	call   80101082 <fileclose>
801041ac:	83 c4 10             	add    $0x10,%esp
  if(*f1)
801041af:	8b 45 0c             	mov    0xc(%ebp),%eax
801041b2:	8b 00                	mov    (%eax),%eax
801041b4:	85 c0                	test   %eax,%eax
801041b6:	74 11                	je     801041c9 <pipealloc+0x14b>
    fileclose(*f1);
801041b8:	8b 45 0c             	mov    0xc(%ebp),%eax
801041bb:	8b 00                	mov    (%eax),%eax
801041bd:	83 ec 0c             	sub    $0xc,%esp
801041c0:	50                   	push   %eax
801041c1:	e8 bc ce ff ff       	call   80101082 <fileclose>
801041c6:	83 c4 10             	add    $0x10,%esp
  return -1;
801041c9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801041ce:	c9                   	leave
801041cf:	c3                   	ret

801041d0 <pipeclose>:

void
pipeclose(struct pipe *p, int writable)
{
801041d0:	55                   	push   %ebp
801041d1:	89 e5                	mov    %esp,%ebp
801041d3:	83 ec 08             	sub    $0x8,%esp
  acquire(&p->lock);
801041d6:	8b 45 08             	mov    0x8(%ebp),%eax
801041d9:	83 ec 0c             	sub    $0xc,%esp
801041dc:	50                   	push   %eax
801041dd:	e8 9d 0e 00 00       	call   8010507f <acquire>
801041e2:	83 c4 10             	add    $0x10,%esp
  if(writable){
801041e5:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
801041e9:	74 23                	je     8010420e <pipeclose+0x3e>
    p->writeopen = 0;
801041eb:	8b 45 08             	mov    0x8(%ebp),%eax
801041ee:	c7 80 40 02 00 00 00 	movl   $0x0,0x240(%eax)
801041f5:	00 00 00 
    wakeup(&p->nread);
801041f8:	8b 45 08             	mov    0x8(%ebp),%eax
801041fb:	05 34 02 00 00       	add    $0x234,%eax
80104200:	83 ec 0c             	sub    $0xc,%esp
80104203:	50                   	push   %eax
80104204:	e8 67 0c 00 00       	call   80104e70 <wakeup>
80104209:	83 c4 10             	add    $0x10,%esp
8010420c:	eb 21                	jmp    8010422f <pipeclose+0x5f>
  } else {
    p->readopen = 0;
8010420e:	8b 45 08             	mov    0x8(%ebp),%eax
80104211:	c7 80 3c 02 00 00 00 	movl   $0x0,0x23c(%eax)
80104218:	00 00 00 
    wakeup(&p->nwrite);
8010421b:	8b 45 08             	mov    0x8(%ebp),%eax
8010421e:	05 38 02 00 00       	add    $0x238,%eax
80104223:	83 ec 0c             	sub    $0xc,%esp
80104226:	50                   	push   %eax
80104227:	e8 44 0c 00 00       	call   80104e70 <wakeup>
8010422c:	83 c4 10             	add    $0x10,%esp
  }
  if(p->readopen == 0 && p->writeopen == 0){
8010422f:	8b 45 08             	mov    0x8(%ebp),%eax
80104232:	8b 80 3c 02 00 00    	mov    0x23c(%eax),%eax
80104238:	85 c0                	test   %eax,%eax
8010423a:	75 2c                	jne    80104268 <pipeclose+0x98>
8010423c:	8b 45 08             	mov    0x8(%ebp),%eax
8010423f:	8b 80 40 02 00 00    	mov    0x240(%eax),%eax
80104245:	85 c0                	test   %eax,%eax
80104247:	75 1f                	jne    80104268 <pipeclose+0x98>
    release(&p->lock);
80104249:	8b 45 08             	mov    0x8(%ebp),%eax
8010424c:	83 ec 0c             	sub    $0xc,%esp
8010424f:	50                   	push   %eax
80104250:	e8 91 0e 00 00       	call   801050e6 <release>
80104255:	83 c4 10             	add    $0x10,%esp
    kfree((char*)p);
80104258:	83 ec 0c             	sub    $0xc,%esp
8010425b:	ff 75 08             	push   0x8(%ebp)
8010425e:	e8 79 e9 ff ff       	call   80102bdc <kfree>
80104263:	83 c4 10             	add    $0x10,%esp
80104266:	eb 10                	jmp    80104278 <pipeclose+0xa8>
  } else
    release(&p->lock);
80104268:	8b 45 08             	mov    0x8(%ebp),%eax
8010426b:	83 ec 0c             	sub    $0xc,%esp
8010426e:	50                   	push   %eax
8010426f:	e8 72 0e 00 00       	call   801050e6 <release>
80104274:	83 c4 10             	add    $0x10,%esp
}
80104277:	90                   	nop
80104278:	90                   	nop
80104279:	c9                   	leave
8010427a:	c3                   	ret

8010427b <pipewrite>:

//PAGEBREAK: 40
int
pipewrite(struct pipe *p, char *addr, int n)
{
8010427b:	55                   	push   %ebp
8010427c:	89 e5                	mov    %esp,%ebp
8010427e:	53                   	push   %ebx
8010427f:	83 ec 14             	sub    $0x14,%esp
  int i;

  acquire(&p->lock);
80104282:	8b 45 08             	mov    0x8(%ebp),%eax
80104285:	83 ec 0c             	sub    $0xc,%esp
80104288:	50                   	push   %eax
80104289:	e8 f1 0d 00 00       	call   8010507f <acquire>
8010428e:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < n; i++){
80104291:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80104298:	e9 ae 00 00 00       	jmp    8010434b <pipewrite+0xd0>
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
      if(p->readopen == 0 || proc->killed){
8010429d:	8b 45 08             	mov    0x8(%ebp),%eax
801042a0:	8b 80 3c 02 00 00    	mov    0x23c(%eax),%eax
801042a6:	85 c0                	test   %eax,%eax
801042a8:	74 0d                	je     801042b7 <pipewrite+0x3c>
801042aa:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801042b0:	8b 40 24             	mov    0x24(%eax),%eax
801042b3:	85 c0                	test   %eax,%eax
801042b5:	74 19                	je     801042d0 <pipewrite+0x55>
        release(&p->lock);
801042b7:	8b 45 08             	mov    0x8(%ebp),%eax
801042ba:	83 ec 0c             	sub    $0xc,%esp
801042bd:	50                   	push   %eax
801042be:	e8 23 0e 00 00       	call   801050e6 <release>
801042c3:	83 c4 10             	add    $0x10,%esp
        return -1;
801042c6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801042cb:	e9 a9 00 00 00       	jmp    80104379 <pipewrite+0xfe>
      }
      wakeup(&p->nread);
801042d0:	8b 45 08             	mov    0x8(%ebp),%eax
801042d3:	05 34 02 00 00       	add    $0x234,%eax
801042d8:	83 ec 0c             	sub    $0xc,%esp
801042db:	50                   	push   %eax
801042dc:	e8 8f 0b 00 00       	call   80104e70 <wakeup>
801042e1:	83 c4 10             	add    $0x10,%esp
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
801042e4:	8b 45 08             	mov    0x8(%ebp),%eax
801042e7:	8b 55 08             	mov    0x8(%ebp),%edx
801042ea:	81 c2 38 02 00 00    	add    $0x238,%edx
801042f0:	83 ec 08             	sub    $0x8,%esp
801042f3:	50                   	push   %eax
801042f4:	52                   	push   %edx
801042f5:	e8 8a 0a 00 00       	call   80104d84 <sleep>
801042fa:	83 c4 10             	add    $0x10,%esp
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
801042fd:	8b 45 08             	mov    0x8(%ebp),%eax
80104300:	8b 90 38 02 00 00    	mov    0x238(%eax),%edx
80104306:	8b 45 08             	mov    0x8(%ebp),%eax
80104309:	8b 80 34 02 00 00    	mov    0x234(%eax),%eax
8010430f:	05 00 02 00 00       	add    $0x200,%eax
80104314:	39 c2                	cmp    %eax,%edx
80104316:	74 85                	je     8010429d <pipewrite+0x22>
    }
    p->data[p->nwrite++ % PIPESIZE] = addr[i];
80104318:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010431b:	8b 45 0c             	mov    0xc(%ebp),%eax
8010431e:	8d 1c 02             	lea    (%edx,%eax,1),%ebx
80104321:	8b 45 08             	mov    0x8(%ebp),%eax
80104324:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
8010432a:	8d 48 01             	lea    0x1(%eax),%ecx
8010432d:	8b 55 08             	mov    0x8(%ebp),%edx
80104330:	89 8a 38 02 00 00    	mov    %ecx,0x238(%edx)
80104336:	25 ff 01 00 00       	and    $0x1ff,%eax
8010433b:	89 c1                	mov    %eax,%ecx
8010433d:	0f b6 13             	movzbl (%ebx),%edx
80104340:	8b 45 08             	mov    0x8(%ebp),%eax
80104343:	88 54 08 34          	mov    %dl,0x34(%eax,%ecx,1)
  for(i = 0; i < n; i++){
80104347:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010434b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010434e:	3b 45 10             	cmp    0x10(%ebp),%eax
80104351:	7c aa                	jl     801042fd <pipewrite+0x82>
  }
  wakeup(&p->nread);  //DOC: pipewrite-wakeup1
80104353:	8b 45 08             	mov    0x8(%ebp),%eax
80104356:	05 34 02 00 00       	add    $0x234,%eax
8010435b:	83 ec 0c             	sub    $0xc,%esp
8010435e:	50                   	push   %eax
8010435f:	e8 0c 0b 00 00       	call   80104e70 <wakeup>
80104364:	83 c4 10             	add    $0x10,%esp
  release(&p->lock);
80104367:	8b 45 08             	mov    0x8(%ebp),%eax
8010436a:	83 ec 0c             	sub    $0xc,%esp
8010436d:	50                   	push   %eax
8010436e:	e8 73 0d 00 00       	call   801050e6 <release>
80104373:	83 c4 10             	add    $0x10,%esp
  return n;
80104376:	8b 45 10             	mov    0x10(%ebp),%eax
}
80104379:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010437c:	c9                   	leave
8010437d:	c3                   	ret

8010437e <piperead>:

int
piperead(struct pipe *p, char *addr, int n)
{
8010437e:	55                   	push   %ebp
8010437f:	89 e5                	mov    %esp,%ebp
80104381:	83 ec 18             	sub    $0x18,%esp
  int i;

  acquire(&p->lock);
80104384:	8b 45 08             	mov    0x8(%ebp),%eax
80104387:	83 ec 0c             	sub    $0xc,%esp
8010438a:	50                   	push   %eax
8010438b:	e8 ef 0c 00 00       	call   8010507f <acquire>
80104390:	83 c4 10             	add    $0x10,%esp
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
80104393:	eb 3f                	jmp    801043d4 <piperead+0x56>
    if(proc->killed){
80104395:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010439b:	8b 40 24             	mov    0x24(%eax),%eax
8010439e:	85 c0                	test   %eax,%eax
801043a0:	74 19                	je     801043bb <piperead+0x3d>
      release(&p->lock);
801043a2:	8b 45 08             	mov    0x8(%ebp),%eax
801043a5:	83 ec 0c             	sub    $0xc,%esp
801043a8:	50                   	push   %eax
801043a9:	e8 38 0d 00 00       	call   801050e6 <release>
801043ae:	83 c4 10             	add    $0x10,%esp
      return -1;
801043b1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801043b6:	e9 be 00 00 00       	jmp    80104479 <piperead+0xfb>
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
801043bb:	8b 45 08             	mov    0x8(%ebp),%eax
801043be:	8b 55 08             	mov    0x8(%ebp),%edx
801043c1:	81 c2 34 02 00 00    	add    $0x234,%edx
801043c7:	83 ec 08             	sub    $0x8,%esp
801043ca:	50                   	push   %eax
801043cb:	52                   	push   %edx
801043cc:	e8 b3 09 00 00       	call   80104d84 <sleep>
801043d1:	83 c4 10             	add    $0x10,%esp
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
801043d4:	8b 45 08             	mov    0x8(%ebp),%eax
801043d7:	8b 90 34 02 00 00    	mov    0x234(%eax),%edx
801043dd:	8b 45 08             	mov    0x8(%ebp),%eax
801043e0:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
801043e6:	39 c2                	cmp    %eax,%edx
801043e8:	75 0d                	jne    801043f7 <piperead+0x79>
801043ea:	8b 45 08             	mov    0x8(%ebp),%eax
801043ed:	8b 80 40 02 00 00    	mov    0x240(%eax),%eax
801043f3:	85 c0                	test   %eax,%eax
801043f5:	75 9e                	jne    80104395 <piperead+0x17>
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
801043f7:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801043fe:	eb 48                	jmp    80104448 <piperead+0xca>
    if(p->nread == p->nwrite)
80104400:	8b 45 08             	mov    0x8(%ebp),%eax
80104403:	8b 90 34 02 00 00    	mov    0x234(%eax),%edx
80104409:	8b 45 08             	mov    0x8(%ebp),%eax
8010440c:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
80104412:	39 c2                	cmp    %eax,%edx
80104414:	74 3c                	je     80104452 <piperead+0xd4>
      break;
    addr[i] = p->data[p->nread++ % PIPESIZE];
80104416:	8b 45 08             	mov    0x8(%ebp),%eax
80104419:	8b 80 34 02 00 00    	mov    0x234(%eax),%eax
8010441f:	8d 48 01             	lea    0x1(%eax),%ecx
80104422:	8b 55 08             	mov    0x8(%ebp),%edx
80104425:	89 8a 34 02 00 00    	mov    %ecx,0x234(%edx)
8010442b:	25 ff 01 00 00       	and    $0x1ff,%eax
80104430:	89 c1                	mov    %eax,%ecx
80104432:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104435:	8b 45 0c             	mov    0xc(%ebp),%eax
80104438:	01 c2                	add    %eax,%edx
8010443a:	8b 45 08             	mov    0x8(%ebp),%eax
8010443d:	0f b6 44 08 34       	movzbl 0x34(%eax,%ecx,1),%eax
80104442:	88 02                	mov    %al,(%edx)
  for(i = 0; i < n; i++){  //DOC: piperead-copy
80104444:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80104448:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010444b:	3b 45 10             	cmp    0x10(%ebp),%eax
8010444e:	7c b0                	jl     80104400 <piperead+0x82>
80104450:	eb 01                	jmp    80104453 <piperead+0xd5>
      break;
80104452:	90                   	nop
  }
  wakeup(&p->nwrite);  //DOC: piperead-wakeup
80104453:	8b 45 08             	mov    0x8(%ebp),%eax
80104456:	05 38 02 00 00       	add    $0x238,%eax
8010445b:	83 ec 0c             	sub    $0xc,%esp
8010445e:	50                   	push   %eax
8010445f:	e8 0c 0a 00 00       	call   80104e70 <wakeup>
80104464:	83 c4 10             	add    $0x10,%esp
  release(&p->lock);
80104467:	8b 45 08             	mov    0x8(%ebp),%eax
8010446a:	83 ec 0c             	sub    $0xc,%esp
8010446d:	50                   	push   %eax
8010446e:	e8 73 0c 00 00       	call   801050e6 <release>
80104473:	83 c4 10             	add    $0x10,%esp
  return i;
80104476:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80104479:	c9                   	leave
8010447a:	c3                   	ret

8010447b <readeflags>:
{
8010447b:	55                   	push   %ebp
8010447c:	89 e5                	mov    %esp,%ebp
8010447e:	83 ec 10             	sub    $0x10,%esp
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80104481:	9c                   	pushf
80104482:	58                   	pop    %eax
80104483:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return eflags;
80104486:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80104489:	c9                   	leave
8010448a:	c3                   	ret

8010448b <sti>:
{
8010448b:	55                   	push   %ebp
8010448c:	89 e5                	mov    %esp,%ebp
  asm volatile("sti");
8010448e:	fb                   	sti
}
8010448f:	90                   	nop
80104490:	5d                   	pop    %ebp
80104491:	c3                   	ret

80104492 <halt>:
}

// CS550: to solve the 100%-CPU-utilization-when-idling problem - "hlt" instruction puts CPU to sleep
static inline void
halt()
{
80104492:	55                   	push   %ebp
80104493:	89 e5                	mov    %esp,%ebp
    asm volatile("hlt" : : :"memory");
80104495:	f4                   	hlt
}
80104496:	90                   	nop
80104497:	5d                   	pop    %ebp
80104498:	c3                   	ret

80104499 <pinit>:

static void wakeup1(void *chan);

void
pinit(void)
{
80104499:	55                   	push   %ebp
8010449a:	89 e5                	mov    %esp,%ebp
8010449c:	83 ec 08             	sub    $0x8,%esp
  initlock(&ptable.lock, "ptable");
8010449f:	83 ec 08             	sub    $0x8,%esp
801044a2:	68 35 8b 10 80       	push   $0x80108b35
801044a7:	68 80 19 11 80       	push   $0x80111980
801044ac:	e8 ac 0b 00 00       	call   8010505d <initlock>
801044b1:	83 c4 10             	add    $0x10,%esp
}
801044b4:	90                   	nop
801044b5:	c9                   	leave
801044b6:	c3                   	ret

801044b7 <allocproc>:
// If found, change state to EMBRYO and initialize
// state required to run in the kernel.
// Otherwise return 0.
static struct proc*
allocproc(void)
{
801044b7:	55                   	push   %ebp
801044b8:	89 e5                	mov    %esp,%ebp
801044ba:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  char *sp;

  acquire(&ptable.lock);
801044bd:	83 ec 0c             	sub    $0xc,%esp
801044c0:	68 80 19 11 80       	push   $0x80111980
801044c5:	e8 b5 0b 00 00       	call   8010507f <acquire>
801044ca:	83 c4 10             	add    $0x10,%esp
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
801044cd:	c7 45 f4 b4 19 11 80 	movl   $0x801119b4,-0xc(%ebp)
801044d4:	eb 0e                	jmp    801044e4 <allocproc+0x2d>
    if(p->state == UNUSED)
801044d6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801044d9:	8b 40 0c             	mov    0xc(%eax),%eax
801044dc:	85 c0                	test   %eax,%eax
801044de:	74 27                	je     80104507 <allocproc+0x50>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
801044e0:	83 45 f4 7c          	addl   $0x7c,-0xc(%ebp)
801044e4:	81 7d f4 b4 38 11 80 	cmpl   $0x801138b4,-0xc(%ebp)
801044eb:	72 e9                	jb     801044d6 <allocproc+0x1f>
      goto found;
  release(&ptable.lock);
801044ed:	83 ec 0c             	sub    $0xc,%esp
801044f0:	68 80 19 11 80       	push   $0x80111980
801044f5:	e8 ec 0b 00 00       	call   801050e6 <release>
801044fa:	83 c4 10             	add    $0x10,%esp
  return 0;
801044fd:	b8 00 00 00 00       	mov    $0x0,%eax
80104502:	e9 b2 00 00 00       	jmp    801045b9 <allocproc+0x102>
      goto found;
80104507:	90                   	nop

found:
  p->state = EMBRYO;
80104508:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010450b:	c7 40 0c 01 00 00 00 	movl   $0x1,0xc(%eax)
  p->pid = nextpid++;
80104512:	a1 04 b0 10 80       	mov    0x8010b004,%eax
80104517:	8d 50 01             	lea    0x1(%eax),%edx
8010451a:	89 15 04 b0 10 80    	mov    %edx,0x8010b004
80104520:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104523:	89 42 10             	mov    %eax,0x10(%edx)
  release(&ptable.lock);
80104526:	83 ec 0c             	sub    $0xc,%esp
80104529:	68 80 19 11 80       	push   $0x80111980
8010452e:	e8 b3 0b 00 00       	call   801050e6 <release>
80104533:	83 c4 10             	add    $0x10,%esp

  // Allocate kernel stack.
  if((p->kstack = kalloc()) == 0){
80104536:	e8 4b e7 ff ff       	call   80102c86 <kalloc>
8010453b:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010453e:	89 42 08             	mov    %eax,0x8(%edx)
80104541:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104544:	8b 40 08             	mov    0x8(%eax),%eax
80104547:	85 c0                	test   %eax,%eax
80104549:	75 11                	jne    8010455c <allocproc+0xa5>
    p->state = UNUSED;
8010454b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010454e:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    return 0;
80104555:	b8 00 00 00 00       	mov    $0x0,%eax
8010455a:	eb 5d                	jmp    801045b9 <allocproc+0x102>
  }
  sp = p->kstack + KSTACKSIZE;
8010455c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010455f:	8b 40 08             	mov    0x8(%eax),%eax
80104562:	05 00 10 00 00       	add    $0x1000,%eax
80104567:	89 45 f0             	mov    %eax,-0x10(%ebp)
  
  // Leave room for trap frame.
  sp -= sizeof *p->tf;
8010456a:	83 6d f0 4c          	subl   $0x4c,-0x10(%ebp)
  p->tf = (struct trapframe*)sp;
8010456e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104571:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104574:	89 50 18             	mov    %edx,0x18(%eax)
  
  // Set up new context to start executing at forkret,
  // which returns to trapret.
  sp -= 4;
80104577:	83 6d f0 04          	subl   $0x4,-0x10(%ebp)
  *(uint*)sp = (uint)trapret;
8010457b:	ba 30 68 10 80       	mov    $0x80106830,%edx
80104580:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104583:	89 10                	mov    %edx,(%eax)

  sp -= sizeof *p->context;
80104585:	83 6d f0 14          	subl   $0x14,-0x10(%ebp)
  p->context = (struct context*)sp;
80104589:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010458c:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010458f:	89 50 1c             	mov    %edx,0x1c(%eax)
  memset(p->context, 0, sizeof *p->context);
80104592:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104595:	8b 40 1c             	mov    0x1c(%eax),%eax
80104598:	83 ec 04             	sub    $0x4,%esp
8010459b:	6a 14                	push   $0x14
8010459d:	6a 00                	push   $0x0
8010459f:	50                   	push   %eax
801045a0:	e8 3e 0d 00 00       	call   801052e3 <memset>
801045a5:	83 c4 10             	add    $0x10,%esp
  p->context->eip = (uint)forkret;
801045a8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801045ab:	8b 40 1c             	mov    0x1c(%eax),%eax
801045ae:	ba 3e 4d 10 80       	mov    $0x80104d3e,%edx
801045b3:	89 50 10             	mov    %edx,0x10(%eax)

  return p;
801045b6:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801045b9:	c9                   	leave
801045ba:	c3                   	ret

801045bb <userinit>:

//PAGEBREAK: 32
// Set up first user process.
void
userinit(void)
{
801045bb:	55                   	push   %ebp
801045bc:	89 e5                	mov    %esp,%ebp
801045be:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  extern char _binary_initcode_start[], _binary_initcode_size[];
  
  p = allocproc();
801045c1:	e8 f1 fe ff ff       	call   801044b7 <allocproc>
801045c6:	89 45 f4             	mov    %eax,-0xc(%ebp)
  initproc = p;
801045c9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801045cc:	a3 b4 38 11 80       	mov    %eax,0x801138b4
  if((p->pgdir = setupkvm()) == 0)
801045d1:	e8 0a 3a 00 00       	call   80107fe0 <setupkvm>
801045d6:	8b 55 f4             	mov    -0xc(%ebp),%edx
801045d9:	89 42 04             	mov    %eax,0x4(%edx)
801045dc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801045df:	8b 40 04             	mov    0x4(%eax),%eax
801045e2:	85 c0                	test   %eax,%eax
801045e4:	75 0d                	jne    801045f3 <userinit+0x38>
    panic("userinit: out of memory?");
801045e6:	83 ec 0c             	sub    $0xc,%esp
801045e9:	68 3c 8b 10 80       	push   $0x80108b3c
801045ee:	e8 86 bf ff ff       	call   80100579 <panic>
  inituvm(p->pgdir, _binary_initcode_start, (int)_binary_initcode_size);
801045f3:	ba 2c 00 00 00       	mov    $0x2c,%edx
801045f8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801045fb:	8b 40 04             	mov    0x4(%eax),%eax
801045fe:	83 ec 04             	sub    $0x4,%esp
80104601:	52                   	push   %edx
80104602:	68 00 b5 10 80       	push   $0x8010b500
80104607:	50                   	push   %eax
80104608:	e8 2e 3c 00 00       	call   8010823b <inituvm>
8010460d:	83 c4 10             	add    $0x10,%esp
  p->sz = PGSIZE;
80104610:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104613:	c7 00 00 10 00 00    	movl   $0x1000,(%eax)
  memset(p->tf, 0, sizeof(*p->tf));
80104619:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010461c:	8b 40 18             	mov    0x18(%eax),%eax
8010461f:	83 ec 04             	sub    $0x4,%esp
80104622:	6a 4c                	push   $0x4c
80104624:	6a 00                	push   $0x0
80104626:	50                   	push   %eax
80104627:	e8 b7 0c 00 00       	call   801052e3 <memset>
8010462c:	83 c4 10             	add    $0x10,%esp
  p->tf->cs = (SEG_UCODE << 3) | DPL_USER;
8010462f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104632:	8b 40 18             	mov    0x18(%eax),%eax
80104635:	66 c7 40 3c 23 00    	movw   $0x23,0x3c(%eax)
  p->tf->ds = (SEG_UDATA << 3) | DPL_USER;
8010463b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010463e:	8b 40 18             	mov    0x18(%eax),%eax
80104641:	66 c7 40 2c 2b 00    	movw   $0x2b,0x2c(%eax)
  p->tf->es = p->tf->ds;
80104647:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010464a:	8b 50 18             	mov    0x18(%eax),%edx
8010464d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104650:	8b 40 18             	mov    0x18(%eax),%eax
80104653:	0f b7 52 2c          	movzwl 0x2c(%edx),%edx
80104657:	66 89 50 28          	mov    %dx,0x28(%eax)
  p->tf->ss = p->tf->ds;
8010465b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010465e:	8b 50 18             	mov    0x18(%eax),%edx
80104661:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104664:	8b 40 18             	mov    0x18(%eax),%eax
80104667:	0f b7 52 2c          	movzwl 0x2c(%edx),%edx
8010466b:	66 89 50 48          	mov    %dx,0x48(%eax)
  p->tf->eflags = FL_IF;
8010466f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104672:	8b 40 18             	mov    0x18(%eax),%eax
80104675:	c7 40 40 00 02 00 00 	movl   $0x200,0x40(%eax)
  p->tf->esp = PGSIZE;
8010467c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010467f:	8b 40 18             	mov    0x18(%eax),%eax
80104682:	c7 40 44 00 10 00 00 	movl   $0x1000,0x44(%eax)
  p->tf->eip = 0;  // beginning of initcode.S
80104689:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010468c:	8b 40 18             	mov    0x18(%eax),%eax
8010468f:	c7 40 38 00 00 00 00 	movl   $0x0,0x38(%eax)

  safestrcpy(p->name, "initcode", sizeof(p->name));
80104696:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104699:	83 c0 6c             	add    $0x6c,%eax
8010469c:	83 ec 04             	sub    $0x4,%esp
8010469f:	6a 10                	push   $0x10
801046a1:	68 55 8b 10 80       	push   $0x80108b55
801046a6:	50                   	push   %eax
801046a7:	e8 3a 0e 00 00       	call   801054e6 <safestrcpy>
801046ac:	83 c4 10             	add    $0x10,%esp
  p->cwd = namei("/");
801046af:	83 ec 0c             	sub    $0xc,%esp
801046b2:	68 5e 8b 10 80       	push   $0x80108b5e
801046b7:	e8 7e de ff ff       	call   8010253a <namei>
801046bc:	83 c4 10             	add    $0x10,%esp
801046bf:	8b 55 f4             	mov    -0xc(%ebp),%edx
801046c2:	89 42 68             	mov    %eax,0x68(%edx)

  p->state = RUNNABLE;
801046c5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801046c8:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
}
801046cf:	90                   	nop
801046d0:	c9                   	leave
801046d1:	c3                   	ret

801046d2 <growproc>:

// Grow current process's memory by n bytes.
// Return 0 on success, -1 on failure.
int
growproc(int n)
{
801046d2:	55                   	push   %ebp
801046d3:	89 e5                	mov    %esp,%ebp
801046d5:	83 ec 18             	sub    $0x18,%esp
  uint sz;
  
  sz = proc->sz;
801046d8:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801046de:	8b 00                	mov    (%eax),%eax
801046e0:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(n > 0){
801046e3:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801046e7:	7e 41                	jle    8010472a <growproc+0x58>
    if((sz = allocuvm(proc->pgdir, sz, sz + n)) == 0)
801046e9:	8b 55 08             	mov    0x8(%ebp),%edx
801046ec:	8b 45 f4             	mov    -0xc(%ebp),%eax
801046ef:	01 c2                	add    %eax,%edx
801046f1:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801046f7:	8b 40 04             	mov    0x4(%eax),%eax
801046fa:	83 ec 04             	sub    $0x4,%esp
801046fd:	52                   	push   %edx
801046fe:	ff 75 f4             	push   -0xc(%ebp)
80104701:	50                   	push   %eax
80104702:	e8 81 3c 00 00       	call   80108388 <allocuvm>
80104707:	83 c4 10             	add    $0x10,%esp
8010470a:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010470d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80104711:	75 5e                	jne    80104771 <growproc+0x9f>
    {
      cprintf("Allocating pages failed!\n"); // CS3320: project 2
80104713:	83 ec 0c             	sub    $0xc,%esp
80104716:	68 60 8b 10 80       	push   $0x80108b60
8010471b:	e8 a4 bc ff ff       	call   801003c4 <cprintf>
80104720:	83 c4 10             	add    $0x10,%esp
      return -1;
80104723:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104728:	eb 69                	jmp    80104793 <growproc+0xc1>
    }
  } else if(n < 0){
8010472a:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
8010472e:	79 41                	jns    80104771 <growproc+0x9f>
    if((sz = deallocuvm(proc->pgdir, sz, sz + n)) == 0)
80104730:	8b 55 08             	mov    0x8(%ebp),%edx
80104733:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104736:	01 c2                	add    %eax,%edx
80104738:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010473e:	8b 40 04             	mov    0x4(%eax),%eax
80104741:	83 ec 04             	sub    $0x4,%esp
80104744:	52                   	push   %edx
80104745:	ff 75 f4             	push   -0xc(%ebp)
80104748:	50                   	push   %eax
80104749:	e8 01 3d 00 00       	call   8010844f <deallocuvm>
8010474e:	83 c4 10             	add    $0x10,%esp
80104751:	89 45 f4             	mov    %eax,-0xc(%ebp)
80104754:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80104758:	75 17                	jne    80104771 <growproc+0x9f>
    {
      cprintf("Deallocating pages failed!\n"); // CS3320: project 2
8010475a:	83 ec 0c             	sub    $0xc,%esp
8010475d:	68 7a 8b 10 80       	push   $0x80108b7a
80104762:	e8 5d bc ff ff       	call   801003c4 <cprintf>
80104767:	83 c4 10             	add    $0x10,%esp
      return -1;
8010476a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010476f:	eb 22                	jmp    80104793 <growproc+0xc1>
    }
  }
  proc->sz = sz;
80104771:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104777:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010477a:	89 10                	mov    %edx,(%eax)
  switchuvm(proc);
8010477c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104782:	83 ec 0c             	sub    $0xc,%esp
80104785:	50                   	push   %eax
80104786:	e8 3c 39 00 00       	call   801080c7 <switchuvm>
8010478b:	83 c4 10             	add    $0x10,%esp
  return 0;
8010478e:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104793:	c9                   	leave
80104794:	c3                   	ret

80104795 <fork>:
// Create a new process copying p as the parent.
// Sets up stack to return as if from system call.
// Caller must set state of returned proc to RUNNABLE.
int
fork(void)
{
80104795:	55                   	push   %ebp
80104796:	89 e5                	mov    %esp,%ebp
80104798:	57                   	push   %edi
80104799:	56                   	push   %esi
8010479a:	53                   	push   %ebx
8010479b:	83 ec 1c             	sub    $0x1c,%esp
  int i, pid;
  struct proc *np;

  // Allocate process.
  if((np = allocproc()) == 0)
8010479e:	e8 14 fd ff ff       	call   801044b7 <allocproc>
801047a3:	89 45 e0             	mov    %eax,-0x20(%ebp)
801047a6:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
801047aa:	75 0a                	jne    801047b6 <fork+0x21>
    return -1;
801047ac:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801047b1:	e9 64 01 00 00       	jmp    8010491a <fork+0x185>

  // Copy process state from p.
  if((np->pgdir = copyuvm(proc->pgdir, proc->sz)) == 0){
801047b6:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801047bc:	8b 10                	mov    (%eax),%edx
801047be:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801047c4:	8b 40 04             	mov    0x4(%eax),%eax
801047c7:	83 ec 08             	sub    $0x8,%esp
801047ca:	52                   	push   %edx
801047cb:	50                   	push   %eax
801047cc:	e8 1c 3e 00 00       	call   801085ed <copyuvm>
801047d1:	83 c4 10             	add    $0x10,%esp
801047d4:	8b 55 e0             	mov    -0x20(%ebp),%edx
801047d7:	89 42 04             	mov    %eax,0x4(%edx)
801047da:	8b 45 e0             	mov    -0x20(%ebp),%eax
801047dd:	8b 40 04             	mov    0x4(%eax),%eax
801047e0:	85 c0                	test   %eax,%eax
801047e2:	75 30                	jne    80104814 <fork+0x7f>
    kfree(np->kstack);
801047e4:	8b 45 e0             	mov    -0x20(%ebp),%eax
801047e7:	8b 40 08             	mov    0x8(%eax),%eax
801047ea:	83 ec 0c             	sub    $0xc,%esp
801047ed:	50                   	push   %eax
801047ee:	e8 e9 e3 ff ff       	call   80102bdc <kfree>
801047f3:	83 c4 10             	add    $0x10,%esp
    np->kstack = 0;
801047f6:	8b 45 e0             	mov    -0x20(%ebp),%eax
801047f9:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
    np->state = UNUSED;
80104800:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104803:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    return -1;
8010480a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010480f:	e9 06 01 00 00       	jmp    8010491a <fork+0x185>
  }
  np->sz = proc->sz;
80104814:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010481a:	8b 10                	mov    (%eax),%edx
8010481c:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010481f:	89 10                	mov    %edx,(%eax)
  np->parent = proc;
80104821:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
80104828:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010482b:	89 50 14             	mov    %edx,0x14(%eax)
  *np->tf = *proc->tf;
8010482e:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104834:	8b 48 18             	mov    0x18(%eax),%ecx
80104837:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010483a:	8b 40 18             	mov    0x18(%eax),%eax
8010483d:	89 c2                	mov    %eax,%edx
8010483f:	89 cb                	mov    %ecx,%ebx
80104841:	b8 13 00 00 00       	mov    $0x13,%eax
80104846:	89 d7                	mov    %edx,%edi
80104848:	89 de                	mov    %ebx,%esi
8010484a:	89 c1                	mov    %eax,%ecx
8010484c:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)

  // Clear %eax so that fork returns 0 in the child.
  np->tf->eax = 0;
8010484e:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104851:	8b 40 18             	mov    0x18(%eax),%eax
80104854:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)

  for(i = 0; i < NOFILE; i++)
8010485b:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
80104862:	eb 41                	jmp    801048a5 <fork+0x110>
    if(proc->ofile[i])
80104864:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010486a:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010486d:	83 c2 08             	add    $0x8,%edx
80104870:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80104874:	85 c0                	test   %eax,%eax
80104876:	74 29                	je     801048a1 <fork+0x10c>
      np->ofile[i] = filedup(proc->ofile[i]);
80104878:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010487e:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80104881:	83 c2 08             	add    $0x8,%edx
80104884:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80104888:	83 ec 0c             	sub    $0xc,%esp
8010488b:	50                   	push   %eax
8010488c:	e8 a0 c7 ff ff       	call   80101031 <filedup>
80104891:	83 c4 10             	add    $0x10,%esp
80104894:	8b 55 e0             	mov    -0x20(%ebp),%edx
80104897:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
8010489a:	83 c1 08             	add    $0x8,%ecx
8010489d:	89 44 8a 08          	mov    %eax,0x8(%edx,%ecx,4)
  for(i = 0; i < NOFILE; i++)
801048a1:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
801048a5:	83 7d e4 0f          	cmpl   $0xf,-0x1c(%ebp)
801048a9:	7e b9                	jle    80104864 <fork+0xcf>
  np->cwd = idup(proc->cwd);
801048ab:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801048b1:	8b 40 68             	mov    0x68(%eax),%eax
801048b4:	83 ec 0c             	sub    $0xc,%esp
801048b7:	50                   	push   %eax
801048b8:	e8 92 d0 ff ff       	call   8010194f <idup>
801048bd:	83 c4 10             	add    $0x10,%esp
801048c0:	8b 55 e0             	mov    -0x20(%ebp),%edx
801048c3:	89 42 68             	mov    %eax,0x68(%edx)

  safestrcpy(np->name, proc->name, sizeof(proc->name));
801048c6:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801048cc:	8d 50 6c             	lea    0x6c(%eax),%edx
801048cf:	8b 45 e0             	mov    -0x20(%ebp),%eax
801048d2:	83 c0 6c             	add    $0x6c,%eax
801048d5:	83 ec 04             	sub    $0x4,%esp
801048d8:	6a 10                	push   $0x10
801048da:	52                   	push   %edx
801048db:	50                   	push   %eax
801048dc:	e8 05 0c 00 00       	call   801054e6 <safestrcpy>
801048e1:	83 c4 10             	add    $0x10,%esp
 
  pid = np->pid;
801048e4:	8b 45 e0             	mov    -0x20(%ebp),%eax
801048e7:	8b 40 10             	mov    0x10(%eax),%eax
801048ea:	89 45 dc             	mov    %eax,-0x24(%ebp)

  // lock to force the compiler to emit the np->state write last.
  acquire(&ptable.lock);
801048ed:	83 ec 0c             	sub    $0xc,%esp
801048f0:	68 80 19 11 80       	push   $0x80111980
801048f5:	e8 85 07 00 00       	call   8010507f <acquire>
801048fa:	83 c4 10             	add    $0x10,%esp
  np->state = RUNNABLE;
801048fd:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104900:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  release(&ptable.lock);
80104907:	83 ec 0c             	sub    $0xc,%esp
8010490a:	68 80 19 11 80       	push   $0x80111980
8010490f:	e8 d2 07 00 00       	call   801050e6 <release>
80104914:	83 c4 10             	add    $0x10,%esp
  
  return pid;
80104917:	8b 45 dc             	mov    -0x24(%ebp),%eax
}
8010491a:	8d 65 f4             	lea    -0xc(%ebp),%esp
8010491d:	5b                   	pop    %ebx
8010491e:	5e                   	pop    %esi
8010491f:	5f                   	pop    %edi
80104920:	5d                   	pop    %ebp
80104921:	c3                   	ret

80104922 <exit>:
// Exit the current process.  Does not return.
// An exited process remains in the zombie state
// until its parent calls wait() to find out it exited.
void
exit(void)
{
80104922:	55                   	push   %ebp
80104923:	89 e5                	mov    %esp,%ebp
80104925:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  int fd;

  if(proc == initproc)
80104928:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
8010492f:	a1 b4 38 11 80       	mov    0x801138b4,%eax
80104934:	39 c2                	cmp    %eax,%edx
80104936:	75 0d                	jne    80104945 <exit+0x23>
    panic("init exiting");
80104938:	83 ec 0c             	sub    $0xc,%esp
8010493b:	68 96 8b 10 80       	push   $0x80108b96
80104940:	e8 34 bc ff ff       	call   80100579 <panic>

  // Close all open files.
  for(fd = 0; fd < NOFILE; fd++){
80104945:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
8010494c:	eb 48                	jmp    80104996 <exit+0x74>
    if(proc->ofile[fd]){
8010494e:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104954:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104957:	83 c2 08             	add    $0x8,%edx
8010495a:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
8010495e:	85 c0                	test   %eax,%eax
80104960:	74 30                	je     80104992 <exit+0x70>
      fileclose(proc->ofile[fd]);
80104962:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104968:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010496b:	83 c2 08             	add    $0x8,%edx
8010496e:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80104972:	83 ec 0c             	sub    $0xc,%esp
80104975:	50                   	push   %eax
80104976:	e8 07 c7 ff ff       	call   80101082 <fileclose>
8010497b:	83 c4 10             	add    $0x10,%esp
      proc->ofile[fd] = 0;
8010497e:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104984:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104987:	83 c2 08             	add    $0x8,%edx
8010498a:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
80104991:	00 
  for(fd = 0; fd < NOFILE; fd++){
80104992:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80104996:	83 7d f0 0f          	cmpl   $0xf,-0x10(%ebp)
8010499a:	7e b2                	jle    8010494e <exit+0x2c>
    }
  }

  begin_op();
8010499c:	e8 cf eb ff ff       	call   80103570 <begin_op>
  iput(proc->cwd);
801049a1:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801049a7:	8b 40 68             	mov    0x68(%eax),%eax
801049aa:	83 ec 0c             	sub    $0xc,%esp
801049ad:	50                   	push   %eax
801049ae:	e8 a6 d1 ff ff       	call   80101b59 <iput>
801049b3:	83 c4 10             	add    $0x10,%esp
  end_op();
801049b6:	e8 41 ec ff ff       	call   801035fc <end_op>
  proc->cwd = 0;
801049bb:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801049c1:	c7 40 68 00 00 00 00 	movl   $0x0,0x68(%eax)

  acquire(&ptable.lock);
801049c8:	83 ec 0c             	sub    $0xc,%esp
801049cb:	68 80 19 11 80       	push   $0x80111980
801049d0:	e8 aa 06 00 00       	call   8010507f <acquire>
801049d5:	83 c4 10             	add    $0x10,%esp

  // Parent might be sleeping in wait().
  wakeup1(proc->parent);
801049d8:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801049de:	8b 40 14             	mov    0x14(%eax),%eax
801049e1:	83 ec 0c             	sub    $0xc,%esp
801049e4:	50                   	push   %eax
801049e5:	e8 46 04 00 00       	call   80104e30 <wakeup1>
801049ea:	83 c4 10             	add    $0x10,%esp

  // Pass abandoned children to init.
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801049ed:	c7 45 f4 b4 19 11 80 	movl   $0x801119b4,-0xc(%ebp)
801049f4:	eb 3c                	jmp    80104a32 <exit+0x110>
    if(p->parent == proc){
801049f6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801049f9:	8b 50 14             	mov    0x14(%eax),%edx
801049fc:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104a02:	39 c2                	cmp    %eax,%edx
80104a04:	75 28                	jne    80104a2e <exit+0x10c>
      p->parent = initproc;
80104a06:	8b 15 b4 38 11 80    	mov    0x801138b4,%edx
80104a0c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104a0f:	89 50 14             	mov    %edx,0x14(%eax)
      if(p->state == ZOMBIE)
80104a12:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104a15:	8b 40 0c             	mov    0xc(%eax),%eax
80104a18:	83 f8 05             	cmp    $0x5,%eax
80104a1b:	75 11                	jne    80104a2e <exit+0x10c>
        wakeup1(initproc);
80104a1d:	a1 b4 38 11 80       	mov    0x801138b4,%eax
80104a22:	83 ec 0c             	sub    $0xc,%esp
80104a25:	50                   	push   %eax
80104a26:	e8 05 04 00 00       	call   80104e30 <wakeup1>
80104a2b:	83 c4 10             	add    $0x10,%esp
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104a2e:	83 45 f4 7c          	addl   $0x7c,-0xc(%ebp)
80104a32:	81 7d f4 b4 38 11 80 	cmpl   $0x801138b4,-0xc(%ebp)
80104a39:	72 bb                	jb     801049f6 <exit+0xd4>
    }
  }

  // Jump into the scheduler, never to return.
  proc->state = ZOMBIE;
80104a3b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104a41:	c7 40 0c 05 00 00 00 	movl   $0x5,0xc(%eax)
  sched();
80104a48:	e8 fa 01 00 00       	call   80104c47 <sched>
  panic("zombie exit");
80104a4d:	83 ec 0c             	sub    $0xc,%esp
80104a50:	68 a3 8b 10 80       	push   $0x80108ba3
80104a55:	e8 1f bb ff ff       	call   80100579 <panic>

80104a5a <wait>:

// Wait for a child process to exit and return its pid.
// Return -1 if this process has no children.
int
wait(void)
{
80104a5a:	55                   	push   %ebp
80104a5b:	89 e5                	mov    %esp,%ebp
80104a5d:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  int havekids, pid;

  acquire(&ptable.lock);
80104a60:	83 ec 0c             	sub    $0xc,%esp
80104a63:	68 80 19 11 80       	push   $0x80111980
80104a68:	e8 12 06 00 00       	call   8010507f <acquire>
80104a6d:	83 c4 10             	add    $0x10,%esp
  for(;;){
    // Scan through table looking for zombie children.
    havekids = 0;
80104a70:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104a77:	c7 45 f4 b4 19 11 80 	movl   $0x801119b4,-0xc(%ebp)
80104a7e:	e9 a6 00 00 00       	jmp    80104b29 <wait+0xcf>
      if(p->parent != proc)
80104a83:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104a86:	8b 50 14             	mov    0x14(%eax),%edx
80104a89:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104a8f:	39 c2                	cmp    %eax,%edx
80104a91:	0f 85 8d 00 00 00    	jne    80104b24 <wait+0xca>
        continue;
      havekids = 1;
80104a97:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
      if(p->state == ZOMBIE){
80104a9e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104aa1:	8b 40 0c             	mov    0xc(%eax),%eax
80104aa4:	83 f8 05             	cmp    $0x5,%eax
80104aa7:	75 7c                	jne    80104b25 <wait+0xcb>
        // Found one.
        pid = p->pid;
80104aa9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104aac:	8b 40 10             	mov    0x10(%eax),%eax
80104aaf:	89 45 ec             	mov    %eax,-0x14(%ebp)
        kfree(p->kstack);
80104ab2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ab5:	8b 40 08             	mov    0x8(%eax),%eax
80104ab8:	83 ec 0c             	sub    $0xc,%esp
80104abb:	50                   	push   %eax
80104abc:	e8 1b e1 ff ff       	call   80102bdc <kfree>
80104ac1:	83 c4 10             	add    $0x10,%esp
        p->kstack = 0;
80104ac4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ac7:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
        freevm(p->pgdir);
80104ace:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ad1:	8b 40 04             	mov    0x4(%eax),%eax
80104ad4:	83 ec 0c             	sub    $0xc,%esp
80104ad7:	50                   	push   %eax
80104ad8:	e8 2f 3a 00 00       	call   8010850c <freevm>
80104add:	83 c4 10             	add    $0x10,%esp
        p->state = UNUSED;
80104ae0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ae3:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
        p->pid = 0;
80104aea:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104aed:	c7 40 10 00 00 00 00 	movl   $0x0,0x10(%eax)
        p->parent = 0;
80104af4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104af7:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
        p->name[0] = 0;
80104afe:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104b01:	c6 40 6c 00          	movb   $0x0,0x6c(%eax)
        p->killed = 0;
80104b05:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104b08:	c7 40 24 00 00 00 00 	movl   $0x0,0x24(%eax)
        release(&ptable.lock);
80104b0f:	83 ec 0c             	sub    $0xc,%esp
80104b12:	68 80 19 11 80       	push   $0x80111980
80104b17:	e8 ca 05 00 00       	call   801050e6 <release>
80104b1c:	83 c4 10             	add    $0x10,%esp
        return pid;
80104b1f:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104b22:	eb 58                	jmp    80104b7c <wait+0x122>
        continue;
80104b24:	90                   	nop
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104b25:	83 45 f4 7c          	addl   $0x7c,-0xc(%ebp)
80104b29:	81 7d f4 b4 38 11 80 	cmpl   $0x801138b4,-0xc(%ebp)
80104b30:	0f 82 4d ff ff ff    	jb     80104a83 <wait+0x29>
      }
    }

    // No point waiting if we don't have any children.
    if(!havekids || proc->killed){
80104b36:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80104b3a:	74 0d                	je     80104b49 <wait+0xef>
80104b3c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104b42:	8b 40 24             	mov    0x24(%eax),%eax
80104b45:	85 c0                	test   %eax,%eax
80104b47:	74 17                	je     80104b60 <wait+0x106>
      release(&ptable.lock);
80104b49:	83 ec 0c             	sub    $0xc,%esp
80104b4c:	68 80 19 11 80       	push   $0x80111980
80104b51:	e8 90 05 00 00       	call   801050e6 <release>
80104b56:	83 c4 10             	add    $0x10,%esp
      return -1;
80104b59:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104b5e:	eb 1c                	jmp    80104b7c <wait+0x122>
    }

    // Wait for children to exit.  (See wakeup1 call in proc_exit.)
    sleep(proc, &ptable.lock);  //DOC: wait-sleep
80104b60:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104b66:	83 ec 08             	sub    $0x8,%esp
80104b69:	68 80 19 11 80       	push   $0x80111980
80104b6e:	50                   	push   %eax
80104b6f:	e8 10 02 00 00       	call   80104d84 <sleep>
80104b74:	83 c4 10             	add    $0x10,%esp
    havekids = 0;
80104b77:	e9 f4 fe ff ff       	jmp    80104a70 <wait+0x16>
  }
}
80104b7c:	c9                   	leave
80104b7d:	c3                   	ret

80104b7e <scheduler>:
//  - swtch to start running that process
//  - eventually that process transfers control
//      via swtch back to the scheduler.
void
scheduler(void)
{
80104b7e:	55                   	push   %ebp
80104b7f:	89 e5                	mov    %esp,%ebp
80104b81:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  int ran = 0; // CS550: to solve the 100%-CPU-utilization-when-idling problem
80104b84:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)

  for(;;){
    // Enable interrupts on this processor.
    sti();
80104b8b:	e8 fb f8 ff ff       	call   8010448b <sti>

    // Loop over process table looking for process to run.
    acquire(&ptable.lock);
80104b90:	83 ec 0c             	sub    $0xc,%esp
80104b93:	68 80 19 11 80       	push   $0x80111980
80104b98:	e8 e2 04 00 00       	call   8010507f <acquire>
80104b9d:	83 c4 10             	add    $0x10,%esp
    ran = 0;
80104ba0:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104ba7:	c7 45 f4 b4 19 11 80 	movl   $0x801119b4,-0xc(%ebp)
80104bae:	eb 6a                	jmp    80104c1a <scheduler+0x9c>
      if(p->state != RUNNABLE)
80104bb0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104bb3:	8b 40 0c             	mov    0xc(%eax),%eax
80104bb6:	83 f8 03             	cmp    $0x3,%eax
80104bb9:	75 5a                	jne    80104c15 <scheduler+0x97>
        continue;

      ran = 1;
80104bbb:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
      
      // Switch to chosen process.  It is the process's job
      // to release ptable.lock and then reacquire it
      // before jumping back to us.
      proc = p;
80104bc2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104bc5:	65 a3 04 00 00 00    	mov    %eax,%gs:0x4
      switchuvm(p);
80104bcb:	83 ec 0c             	sub    $0xc,%esp
80104bce:	ff 75 f4             	push   -0xc(%ebp)
80104bd1:	e8 f1 34 00 00       	call   801080c7 <switchuvm>
80104bd6:	83 c4 10             	add    $0x10,%esp
      p->state = RUNNING;
80104bd9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104bdc:	c7 40 0c 04 00 00 00 	movl   $0x4,0xc(%eax)
      swtch(&cpu->scheduler, proc->context);
80104be3:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104be9:	8b 40 1c             	mov    0x1c(%eax),%eax
80104bec:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80104bf3:	83 c2 04             	add    $0x4,%edx
80104bf6:	83 ec 08             	sub    $0x8,%esp
80104bf9:	50                   	push   %eax
80104bfa:	52                   	push   %edx
80104bfb:	e8 58 09 00 00       	call   80105558 <swtch>
80104c00:	83 c4 10             	add    $0x10,%esp
      switchkvm();
80104c03:	e8 a2 34 00 00       	call   801080aa <switchkvm>

      // Process is done running for now.
      // It should have changed its p->state before coming back.
      proc = 0;
80104c08:	65 c7 05 04 00 00 00 	movl   $0x0,%gs:0x4
80104c0f:	00 00 00 00 
80104c13:	eb 01                	jmp    80104c16 <scheduler+0x98>
        continue;
80104c15:	90                   	nop
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104c16:	83 45 f4 7c          	addl   $0x7c,-0xc(%ebp)
80104c1a:	81 7d f4 b4 38 11 80 	cmpl   $0x801138b4,-0xc(%ebp)
80104c21:	72 8d                	jb     80104bb0 <scheduler+0x32>
    }
    release(&ptable.lock);
80104c23:	83 ec 0c             	sub    $0xc,%esp
80104c26:	68 80 19 11 80       	push   $0x80111980
80104c2b:	e8 b6 04 00 00       	call   801050e6 <release>
80104c30:	83 c4 10             	add    $0x10,%esp

    if (ran == 0){
80104c33:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80104c37:	0f 85 4e ff ff ff    	jne    80104b8b <scheduler+0xd>
        halt();
80104c3d:	e8 50 f8 ff ff       	call   80104492 <halt>
    sti();
80104c42:	e9 44 ff ff ff       	jmp    80104b8b <scheduler+0xd>

80104c47 <sched>:

// Enter scheduler.  Must hold only ptable.lock
// and have changed proc->state.
void
sched(void)
{
80104c47:	55                   	push   %ebp
80104c48:	89 e5                	mov    %esp,%ebp
80104c4a:	83 ec 18             	sub    $0x18,%esp
  int intena;

  if(!holding(&ptable.lock))
80104c4d:	83 ec 0c             	sub    $0xc,%esp
80104c50:	68 80 19 11 80       	push   $0x80111980
80104c55:	e8 59 05 00 00       	call   801051b3 <holding>
80104c5a:	83 c4 10             	add    $0x10,%esp
80104c5d:	85 c0                	test   %eax,%eax
80104c5f:	75 0d                	jne    80104c6e <sched+0x27>
    panic("sched ptable.lock");
80104c61:	83 ec 0c             	sub    $0xc,%esp
80104c64:	68 af 8b 10 80       	push   $0x80108baf
80104c69:	e8 0b b9 ff ff       	call   80100579 <panic>
  if(cpu->ncli != 1)
80104c6e:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80104c74:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
80104c7a:	83 f8 01             	cmp    $0x1,%eax
80104c7d:	74 0d                	je     80104c8c <sched+0x45>
    panic("sched locks");
80104c7f:	83 ec 0c             	sub    $0xc,%esp
80104c82:	68 c1 8b 10 80       	push   $0x80108bc1
80104c87:	e8 ed b8 ff ff       	call   80100579 <panic>
  if(proc->state == RUNNING)
80104c8c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104c92:	8b 40 0c             	mov    0xc(%eax),%eax
80104c95:	83 f8 04             	cmp    $0x4,%eax
80104c98:	75 0d                	jne    80104ca7 <sched+0x60>
    panic("sched running");
80104c9a:	83 ec 0c             	sub    $0xc,%esp
80104c9d:	68 cd 8b 10 80       	push   $0x80108bcd
80104ca2:	e8 d2 b8 ff ff       	call   80100579 <panic>
  if(readeflags()&FL_IF)
80104ca7:	e8 cf f7 ff ff       	call   8010447b <readeflags>
80104cac:	25 00 02 00 00       	and    $0x200,%eax
80104cb1:	85 c0                	test   %eax,%eax
80104cb3:	74 0d                	je     80104cc2 <sched+0x7b>
    panic("sched interruptible");
80104cb5:	83 ec 0c             	sub    $0xc,%esp
80104cb8:	68 db 8b 10 80       	push   $0x80108bdb
80104cbd:	e8 b7 b8 ff ff       	call   80100579 <panic>
  intena = cpu->intena;
80104cc2:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80104cc8:	8b 80 b0 00 00 00    	mov    0xb0(%eax),%eax
80104cce:	89 45 f4             	mov    %eax,-0xc(%ebp)
  swtch(&proc->context, cpu->scheduler);
80104cd1:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80104cd7:	8b 40 04             	mov    0x4(%eax),%eax
80104cda:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
80104ce1:	83 c2 1c             	add    $0x1c,%edx
80104ce4:	83 ec 08             	sub    $0x8,%esp
80104ce7:	50                   	push   %eax
80104ce8:	52                   	push   %edx
80104ce9:	e8 6a 08 00 00       	call   80105558 <swtch>
80104cee:	83 c4 10             	add    $0x10,%esp
  cpu->intena = intena;
80104cf1:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80104cf7:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104cfa:	89 90 b0 00 00 00    	mov    %edx,0xb0(%eax)
}
80104d00:	90                   	nop
80104d01:	c9                   	leave
80104d02:	c3                   	ret

80104d03 <yield>:

// Give up the CPU for one scheduling round.
void
yield(void)
{
80104d03:	55                   	push   %ebp
80104d04:	89 e5                	mov    %esp,%ebp
80104d06:	83 ec 08             	sub    $0x8,%esp
  acquire(&ptable.lock);  //DOC: yieldlock
80104d09:	83 ec 0c             	sub    $0xc,%esp
80104d0c:	68 80 19 11 80       	push   $0x80111980
80104d11:	e8 69 03 00 00       	call   8010507f <acquire>
80104d16:	83 c4 10             	add    $0x10,%esp
  proc->state = RUNNABLE;
80104d19:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104d1f:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  sched();
80104d26:	e8 1c ff ff ff       	call   80104c47 <sched>
  release(&ptable.lock);
80104d2b:	83 ec 0c             	sub    $0xc,%esp
80104d2e:	68 80 19 11 80       	push   $0x80111980
80104d33:	e8 ae 03 00 00       	call   801050e6 <release>
80104d38:	83 c4 10             	add    $0x10,%esp
}
80104d3b:	90                   	nop
80104d3c:	c9                   	leave
80104d3d:	c3                   	ret

80104d3e <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch here.  "Return" to user space.
void
forkret(void)
{
80104d3e:	55                   	push   %ebp
80104d3f:	89 e5                	mov    %esp,%ebp
80104d41:	83 ec 08             	sub    $0x8,%esp
  static int first = 1;
  // Still holding ptable.lock from scheduler.
  release(&ptable.lock);
80104d44:	83 ec 0c             	sub    $0xc,%esp
80104d47:	68 80 19 11 80       	push   $0x80111980
80104d4c:	e8 95 03 00 00       	call   801050e6 <release>
80104d51:	83 c4 10             	add    $0x10,%esp

  if (first) {
80104d54:	a1 08 b0 10 80       	mov    0x8010b008,%eax
80104d59:	85 c0                	test   %eax,%eax
80104d5b:	74 24                	je     80104d81 <forkret+0x43>
    // Some initialization functions must be run in the context
    // of a regular process (e.g., they call sleep), and thus cannot 
    // be run from main().
    first = 0;
80104d5d:	c7 05 08 b0 10 80 00 	movl   $0x0,0x8010b008
80104d64:	00 00 00 
    iinit(ROOTDEV);
80104d67:	83 ec 0c             	sub    $0xc,%esp
80104d6a:	6a 01                	push   $0x1
80104d6c:	e8 ed c8 ff ff       	call   8010165e <iinit>
80104d71:	83 c4 10             	add    $0x10,%esp
    initlog(ROOTDEV);
80104d74:	83 ec 0c             	sub    $0xc,%esp
80104d77:	6a 01                	push   $0x1
80104d79:	e8 d3 e5 ff ff       	call   80103351 <initlog>
80104d7e:	83 c4 10             	add    $0x10,%esp
  }
  
  // Return to "caller", actually trapret (see allocproc).
}
80104d81:	90                   	nop
80104d82:	c9                   	leave
80104d83:	c3                   	ret

80104d84 <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
80104d84:	55                   	push   %ebp
80104d85:	89 e5                	mov    %esp,%ebp
80104d87:	83 ec 08             	sub    $0x8,%esp
  if(proc == 0)
80104d8a:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104d90:	85 c0                	test   %eax,%eax
80104d92:	75 0d                	jne    80104da1 <sleep+0x1d>
    panic("sleep");
80104d94:	83 ec 0c             	sub    $0xc,%esp
80104d97:	68 ef 8b 10 80       	push   $0x80108bef
80104d9c:	e8 d8 b7 ff ff       	call   80100579 <panic>

  if(lk == 0)
80104da1:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80104da5:	75 0d                	jne    80104db4 <sleep+0x30>
    panic("sleep without lk");
80104da7:	83 ec 0c             	sub    $0xc,%esp
80104daa:	68 f5 8b 10 80       	push   $0x80108bf5
80104daf:	e8 c5 b7 ff ff       	call   80100579 <panic>
  // change p->state and then call sched.
  // Once we hold ptable.lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup runs with ptable.lock locked),
  // so it's okay to release lk.
  if(lk != &ptable.lock){  //DOC: sleeplock0
80104db4:	81 7d 0c 80 19 11 80 	cmpl   $0x80111980,0xc(%ebp)
80104dbb:	74 1e                	je     80104ddb <sleep+0x57>
    acquire(&ptable.lock);  //DOC: sleeplock1
80104dbd:	83 ec 0c             	sub    $0xc,%esp
80104dc0:	68 80 19 11 80       	push   $0x80111980
80104dc5:	e8 b5 02 00 00       	call   8010507f <acquire>
80104dca:	83 c4 10             	add    $0x10,%esp
    release(lk);
80104dcd:	83 ec 0c             	sub    $0xc,%esp
80104dd0:	ff 75 0c             	push   0xc(%ebp)
80104dd3:	e8 0e 03 00 00       	call   801050e6 <release>
80104dd8:	83 c4 10             	add    $0x10,%esp
  }

  // Go to sleep.
  proc->chan = chan;
80104ddb:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104de1:	8b 55 08             	mov    0x8(%ebp),%edx
80104de4:	89 50 20             	mov    %edx,0x20(%eax)
  proc->state = SLEEPING;
80104de7:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104ded:	c7 40 0c 02 00 00 00 	movl   $0x2,0xc(%eax)
  sched();
80104df4:	e8 4e fe ff ff       	call   80104c47 <sched>

  // Tidy up.
  proc->chan = 0;
80104df9:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104dff:	c7 40 20 00 00 00 00 	movl   $0x0,0x20(%eax)

  // Reacquire original lock.
  if(lk != &ptable.lock){  //DOC: sleeplock2
80104e06:	81 7d 0c 80 19 11 80 	cmpl   $0x80111980,0xc(%ebp)
80104e0d:	74 1e                	je     80104e2d <sleep+0xa9>
    release(&ptable.lock);
80104e0f:	83 ec 0c             	sub    $0xc,%esp
80104e12:	68 80 19 11 80       	push   $0x80111980
80104e17:	e8 ca 02 00 00       	call   801050e6 <release>
80104e1c:	83 c4 10             	add    $0x10,%esp
    acquire(lk);
80104e1f:	83 ec 0c             	sub    $0xc,%esp
80104e22:	ff 75 0c             	push   0xc(%ebp)
80104e25:	e8 55 02 00 00       	call   8010507f <acquire>
80104e2a:	83 c4 10             	add    $0x10,%esp
  }
}
80104e2d:	90                   	nop
80104e2e:	c9                   	leave
80104e2f:	c3                   	ret

80104e30 <wakeup1>:
//PAGEBREAK!
// Wake up all processes sleeping on chan.
// The ptable lock must be held.
static void
wakeup1(void *chan)
{
80104e30:	55                   	push   %ebp
80104e31:	89 e5                	mov    %esp,%ebp
80104e33:	83 ec 10             	sub    $0x10,%esp
  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104e36:	c7 45 fc b4 19 11 80 	movl   $0x801119b4,-0x4(%ebp)
80104e3d:	eb 24                	jmp    80104e63 <wakeup1+0x33>
    if(p->state == SLEEPING && p->chan == chan)
80104e3f:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104e42:	8b 40 0c             	mov    0xc(%eax),%eax
80104e45:	83 f8 02             	cmp    $0x2,%eax
80104e48:	75 15                	jne    80104e5f <wakeup1+0x2f>
80104e4a:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104e4d:	8b 40 20             	mov    0x20(%eax),%eax
80104e50:	39 45 08             	cmp    %eax,0x8(%ebp)
80104e53:	75 0a                	jne    80104e5f <wakeup1+0x2f>
      p->state = RUNNABLE;
80104e55:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104e58:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104e5f:	83 45 fc 7c          	addl   $0x7c,-0x4(%ebp)
80104e63:	81 7d fc b4 38 11 80 	cmpl   $0x801138b4,-0x4(%ebp)
80104e6a:	72 d3                	jb     80104e3f <wakeup1+0xf>
}
80104e6c:	90                   	nop
80104e6d:	90                   	nop
80104e6e:	c9                   	leave
80104e6f:	c3                   	ret

80104e70 <wakeup>:

// Wake up all processes sleeping on chan.
void
wakeup(void *chan)
{
80104e70:	55                   	push   %ebp
80104e71:	89 e5                	mov    %esp,%ebp
80104e73:	83 ec 08             	sub    $0x8,%esp
  acquire(&ptable.lock);
80104e76:	83 ec 0c             	sub    $0xc,%esp
80104e79:	68 80 19 11 80       	push   $0x80111980
80104e7e:	e8 fc 01 00 00       	call   8010507f <acquire>
80104e83:	83 c4 10             	add    $0x10,%esp
  wakeup1(chan);
80104e86:	83 ec 0c             	sub    $0xc,%esp
80104e89:	ff 75 08             	push   0x8(%ebp)
80104e8c:	e8 9f ff ff ff       	call   80104e30 <wakeup1>
80104e91:	83 c4 10             	add    $0x10,%esp
  release(&ptable.lock);
80104e94:	83 ec 0c             	sub    $0xc,%esp
80104e97:	68 80 19 11 80       	push   $0x80111980
80104e9c:	e8 45 02 00 00       	call   801050e6 <release>
80104ea1:	83 c4 10             	add    $0x10,%esp
}
80104ea4:	90                   	nop
80104ea5:	c9                   	leave
80104ea6:	c3                   	ret

80104ea7 <kill>:
// Kill the process with the given pid.
// Process won't exit until it returns
// to user space (see trap in trap.c).
int
kill(int pid)
{
80104ea7:	55                   	push   %ebp
80104ea8:	89 e5                	mov    %esp,%ebp
80104eaa:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;

  acquire(&ptable.lock);
80104ead:	83 ec 0c             	sub    $0xc,%esp
80104eb0:	68 80 19 11 80       	push   $0x80111980
80104eb5:	e8 c5 01 00 00       	call   8010507f <acquire>
80104eba:	83 c4 10             	add    $0x10,%esp
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104ebd:	c7 45 f4 b4 19 11 80 	movl   $0x801119b4,-0xc(%ebp)
80104ec4:	eb 45                	jmp    80104f0b <kill+0x64>
    if(p->pid == pid){
80104ec6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ec9:	8b 40 10             	mov    0x10(%eax),%eax
80104ecc:	39 45 08             	cmp    %eax,0x8(%ebp)
80104ecf:	75 36                	jne    80104f07 <kill+0x60>
      p->killed = 1;
80104ed1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ed4:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
      // Wake process from sleep if necessary.
      if(p->state == SLEEPING)
80104edb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ede:	8b 40 0c             	mov    0xc(%eax),%eax
80104ee1:	83 f8 02             	cmp    $0x2,%eax
80104ee4:	75 0a                	jne    80104ef0 <kill+0x49>
        p->state = RUNNABLE;
80104ee6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ee9:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
      release(&ptable.lock);
80104ef0:	83 ec 0c             	sub    $0xc,%esp
80104ef3:	68 80 19 11 80       	push   $0x80111980
80104ef8:	e8 e9 01 00 00       	call   801050e6 <release>
80104efd:	83 c4 10             	add    $0x10,%esp
      return 0;
80104f00:	b8 00 00 00 00       	mov    $0x0,%eax
80104f05:	eb 22                	jmp    80104f29 <kill+0x82>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104f07:	83 45 f4 7c          	addl   $0x7c,-0xc(%ebp)
80104f0b:	81 7d f4 b4 38 11 80 	cmpl   $0x801138b4,-0xc(%ebp)
80104f12:	72 b2                	jb     80104ec6 <kill+0x1f>
    }
  }
  release(&ptable.lock);
80104f14:	83 ec 0c             	sub    $0xc,%esp
80104f17:	68 80 19 11 80       	push   $0x80111980
80104f1c:	e8 c5 01 00 00       	call   801050e6 <release>
80104f21:	83 c4 10             	add    $0x10,%esp
  return -1;
80104f24:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80104f29:	c9                   	leave
80104f2a:	c3                   	ret

80104f2b <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
80104f2b:	55                   	push   %ebp
80104f2c:	89 e5                	mov    %esp,%ebp
80104f2e:	83 ec 48             	sub    $0x48,%esp
  int i;
  struct proc *p;
  char *state;
  uint pc[10];
  
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104f31:	c7 45 f0 b4 19 11 80 	movl   $0x801119b4,-0x10(%ebp)
80104f38:	e9 d7 00 00 00       	jmp    80105014 <procdump+0xe9>
    if(p->state == UNUSED)
80104f3d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104f40:	8b 40 0c             	mov    0xc(%eax),%eax
80104f43:	85 c0                	test   %eax,%eax
80104f45:	0f 84 c4 00 00 00    	je     8010500f <procdump+0xe4>
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
80104f4b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104f4e:	8b 40 0c             	mov    0xc(%eax),%eax
80104f51:	83 f8 05             	cmp    $0x5,%eax
80104f54:	77 23                	ja     80104f79 <procdump+0x4e>
80104f56:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104f59:	8b 40 0c             	mov    0xc(%eax),%eax
80104f5c:	8b 04 85 0c b0 10 80 	mov    -0x7fef4ff4(,%eax,4),%eax
80104f63:	85 c0                	test   %eax,%eax
80104f65:	74 12                	je     80104f79 <procdump+0x4e>
      state = states[p->state];
80104f67:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104f6a:	8b 40 0c             	mov    0xc(%eax),%eax
80104f6d:	8b 04 85 0c b0 10 80 	mov    -0x7fef4ff4(,%eax,4),%eax
80104f74:	89 45 ec             	mov    %eax,-0x14(%ebp)
80104f77:	eb 07                	jmp    80104f80 <procdump+0x55>
    else
      state = "???";
80104f79:	c7 45 ec 06 8c 10 80 	movl   $0x80108c06,-0x14(%ebp)
    cprintf("%d %s %s", p->pid, state, p->name);
80104f80:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104f83:	8d 50 6c             	lea    0x6c(%eax),%edx
80104f86:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104f89:	8b 40 10             	mov    0x10(%eax),%eax
80104f8c:	52                   	push   %edx
80104f8d:	ff 75 ec             	push   -0x14(%ebp)
80104f90:	50                   	push   %eax
80104f91:	68 0a 8c 10 80       	push   $0x80108c0a
80104f96:	e8 29 b4 ff ff       	call   801003c4 <cprintf>
80104f9b:	83 c4 10             	add    $0x10,%esp
    if(p->state == SLEEPING){
80104f9e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104fa1:	8b 40 0c             	mov    0xc(%eax),%eax
80104fa4:	83 f8 02             	cmp    $0x2,%eax
80104fa7:	75 54                	jne    80104ffd <procdump+0xd2>
      getcallerpcs((uint*)p->context->ebp+2, pc);
80104fa9:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104fac:	8b 40 1c             	mov    0x1c(%eax),%eax
80104faf:	8b 40 0c             	mov    0xc(%eax),%eax
80104fb2:	83 c0 08             	add    $0x8,%eax
80104fb5:	89 c2                	mov    %eax,%edx
80104fb7:	83 ec 08             	sub    $0x8,%esp
80104fba:	8d 45 c4             	lea    -0x3c(%ebp),%eax
80104fbd:	50                   	push   %eax
80104fbe:	52                   	push   %edx
80104fbf:	e8 74 01 00 00       	call   80105138 <getcallerpcs>
80104fc4:	83 c4 10             	add    $0x10,%esp
      for(i=0; i<10 && pc[i] != 0; i++)
80104fc7:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80104fce:	eb 1c                	jmp    80104fec <procdump+0xc1>
        cprintf(" %p", pc[i]);
80104fd0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104fd3:	8b 44 85 c4          	mov    -0x3c(%ebp,%eax,4),%eax
80104fd7:	83 ec 08             	sub    $0x8,%esp
80104fda:	50                   	push   %eax
80104fdb:	68 13 8c 10 80       	push   $0x80108c13
80104fe0:	e8 df b3 ff ff       	call   801003c4 <cprintf>
80104fe5:	83 c4 10             	add    $0x10,%esp
      for(i=0; i<10 && pc[i] != 0; i++)
80104fe8:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80104fec:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
80104ff0:	7f 0b                	jg     80104ffd <procdump+0xd2>
80104ff2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ff5:	8b 44 85 c4          	mov    -0x3c(%ebp,%eax,4),%eax
80104ff9:	85 c0                	test   %eax,%eax
80104ffb:	75 d3                	jne    80104fd0 <procdump+0xa5>
    }
    cprintf("\n");
80104ffd:	83 ec 0c             	sub    $0xc,%esp
80105000:	68 17 8c 10 80       	push   $0x80108c17
80105005:	e8 ba b3 ff ff       	call   801003c4 <cprintf>
8010500a:	83 c4 10             	add    $0x10,%esp
8010500d:	eb 01                	jmp    80105010 <procdump+0xe5>
      continue;
8010500f:	90                   	nop
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80105010:	83 45 f0 7c          	addl   $0x7c,-0x10(%ebp)
80105014:	81 7d f0 b4 38 11 80 	cmpl   $0x801138b4,-0x10(%ebp)
8010501b:	0f 82 1c ff ff ff    	jb     80104f3d <procdump+0x12>
  }
}
80105021:	90                   	nop
80105022:	90                   	nop
80105023:	c9                   	leave
80105024:	c3                   	ret

80105025 <readeflags>:
{
80105025:	55                   	push   %ebp
80105026:	89 e5                	mov    %esp,%ebp
80105028:	83 ec 10             	sub    $0x10,%esp
  asm volatile("pushfl; popl %0" : "=r" (eflags));
8010502b:	9c                   	pushf
8010502c:	58                   	pop    %eax
8010502d:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return eflags;
80105030:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80105033:	c9                   	leave
80105034:	c3                   	ret

80105035 <cli>:
{
80105035:	55                   	push   %ebp
80105036:	89 e5                	mov    %esp,%ebp
  asm volatile("cli");
80105038:	fa                   	cli
}
80105039:	90                   	nop
8010503a:	5d                   	pop    %ebp
8010503b:	c3                   	ret

8010503c <sti>:
{
8010503c:	55                   	push   %ebp
8010503d:	89 e5                	mov    %esp,%ebp
  asm volatile("sti");
8010503f:	fb                   	sti
}
80105040:	90                   	nop
80105041:	5d                   	pop    %ebp
80105042:	c3                   	ret

80105043 <xchg>:
{
80105043:	55                   	push   %ebp
80105044:	89 e5                	mov    %esp,%ebp
80105046:	83 ec 10             	sub    $0x10,%esp
  asm volatile("lock; xchgl %0, %1" :
80105049:	8b 55 08             	mov    0x8(%ebp),%edx
8010504c:	8b 45 0c             	mov    0xc(%ebp),%eax
8010504f:	8b 4d 08             	mov    0x8(%ebp),%ecx
80105052:	f0 87 02             	lock xchg %eax,(%edx)
80105055:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return result;
80105058:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
8010505b:	c9                   	leave
8010505c:	c3                   	ret

8010505d <initlock>:
#include "proc.h"
#include "spinlock.h"

void
initlock(struct spinlock *lk, char *name)
{
8010505d:	55                   	push   %ebp
8010505e:	89 e5                	mov    %esp,%ebp
  lk->name = name;
80105060:	8b 45 08             	mov    0x8(%ebp),%eax
80105063:	8b 55 0c             	mov    0xc(%ebp),%edx
80105066:	89 50 04             	mov    %edx,0x4(%eax)
  lk->locked = 0;
80105069:	8b 45 08             	mov    0x8(%ebp),%eax
8010506c:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->cpu = 0;
80105072:	8b 45 08             	mov    0x8(%ebp),%eax
80105075:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
}
8010507c:	90                   	nop
8010507d:	5d                   	pop    %ebp
8010507e:	c3                   	ret

8010507f <acquire>:
// Loops (spins) until the lock is acquired.
// Holding a lock for a long time may cause
// other CPUs to waste time spinning to acquire it.
void
acquire(struct spinlock *lk)
{
8010507f:	55                   	push   %ebp
80105080:	89 e5                	mov    %esp,%ebp
80105082:	83 ec 08             	sub    $0x8,%esp
  pushcli(); // disable interrupts to avoid deadlock.
80105085:	e8 53 01 00 00       	call   801051dd <pushcli>
  if(holding(lk))
8010508a:	8b 45 08             	mov    0x8(%ebp),%eax
8010508d:	83 ec 0c             	sub    $0xc,%esp
80105090:	50                   	push   %eax
80105091:	e8 1d 01 00 00       	call   801051b3 <holding>
80105096:	83 c4 10             	add    $0x10,%esp
80105099:	85 c0                	test   %eax,%eax
8010509b:	74 0d                	je     801050aa <acquire+0x2b>
    panic("acquire");
8010509d:	83 ec 0c             	sub    $0xc,%esp
801050a0:	68 43 8c 10 80       	push   $0x80108c43
801050a5:	e8 cf b4 ff ff       	call   80100579 <panic>

  // The xchg is atomic.
  // It also serializes, so that reads after acquire are not
  // reordered before it. 
  while(xchg(&lk->locked, 1) != 0)
801050aa:	90                   	nop
801050ab:	8b 45 08             	mov    0x8(%ebp),%eax
801050ae:	83 ec 08             	sub    $0x8,%esp
801050b1:	6a 01                	push   $0x1
801050b3:	50                   	push   %eax
801050b4:	e8 8a ff ff ff       	call   80105043 <xchg>
801050b9:	83 c4 10             	add    $0x10,%esp
801050bc:	85 c0                	test   %eax,%eax
801050be:	75 eb                	jne    801050ab <acquire+0x2c>
    ;

  // Record info about lock acquisition for debugging.
  lk->cpu = cpu;
801050c0:	8b 45 08             	mov    0x8(%ebp),%eax
801050c3:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
801050ca:	89 50 08             	mov    %edx,0x8(%eax)
  getcallerpcs(&lk, lk->pcs);
801050cd:	8b 45 08             	mov    0x8(%ebp),%eax
801050d0:	83 c0 0c             	add    $0xc,%eax
801050d3:	83 ec 08             	sub    $0x8,%esp
801050d6:	50                   	push   %eax
801050d7:	8d 45 08             	lea    0x8(%ebp),%eax
801050da:	50                   	push   %eax
801050db:	e8 58 00 00 00       	call   80105138 <getcallerpcs>
801050e0:	83 c4 10             	add    $0x10,%esp
}
801050e3:	90                   	nop
801050e4:	c9                   	leave
801050e5:	c3                   	ret

801050e6 <release>:

// Release the lock.
void
release(struct spinlock *lk)
{
801050e6:	55                   	push   %ebp
801050e7:	89 e5                	mov    %esp,%ebp
801050e9:	83 ec 08             	sub    $0x8,%esp
  if(!holding(lk))
801050ec:	83 ec 0c             	sub    $0xc,%esp
801050ef:	ff 75 08             	push   0x8(%ebp)
801050f2:	e8 bc 00 00 00       	call   801051b3 <holding>
801050f7:	83 c4 10             	add    $0x10,%esp
801050fa:	85 c0                	test   %eax,%eax
801050fc:	75 0d                	jne    8010510b <release+0x25>
    panic("release");
801050fe:	83 ec 0c             	sub    $0xc,%esp
80105101:	68 4b 8c 10 80       	push   $0x80108c4b
80105106:	e8 6e b4 ff ff       	call   80100579 <panic>

  lk->pcs[0] = 0;
8010510b:	8b 45 08             	mov    0x8(%ebp),%eax
8010510e:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
  lk->cpu = 0;
80105115:	8b 45 08             	mov    0x8(%ebp),%eax
80105118:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
  // But the 2007 Intel 64 Architecture Memory Ordering White
  // Paper says that Intel 64 and IA-32 will not move a load
  // after a store. So lock->locked = 0 would work here.
  // The xchg being asm volatile ensures gcc emits it after
  // the above assignments (and after the critical section).
  xchg(&lk->locked, 0);
8010511f:	8b 45 08             	mov    0x8(%ebp),%eax
80105122:	83 ec 08             	sub    $0x8,%esp
80105125:	6a 00                	push   $0x0
80105127:	50                   	push   %eax
80105128:	e8 16 ff ff ff       	call   80105043 <xchg>
8010512d:	83 c4 10             	add    $0x10,%esp

  popcli();
80105130:	e8 ed 00 00 00       	call   80105222 <popcli>
}
80105135:	90                   	nop
80105136:	c9                   	leave
80105137:	c3                   	ret

80105138 <getcallerpcs>:

// Record the current call stack in pcs[] by following the %ebp chain.
void
getcallerpcs(void *v, uint pcs[])
{
80105138:	55                   	push   %ebp
80105139:	89 e5                	mov    %esp,%ebp
8010513b:	83 ec 10             	sub    $0x10,%esp
  uint *ebp;
  int i;
  
  ebp = (uint*)v - 2;
8010513e:	8b 45 08             	mov    0x8(%ebp),%eax
80105141:	83 e8 08             	sub    $0x8,%eax
80105144:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(i = 0; i < 10; i++){
80105147:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
8010514e:	eb 38                	jmp    80105188 <getcallerpcs+0x50>
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
80105150:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
80105154:	74 53                	je     801051a9 <getcallerpcs+0x71>
80105156:	81 7d fc ff ff ff 7f 	cmpl   $0x7fffffff,-0x4(%ebp)
8010515d:	76 4a                	jbe    801051a9 <getcallerpcs+0x71>
8010515f:	83 7d fc ff          	cmpl   $0xffffffff,-0x4(%ebp)
80105163:	74 44                	je     801051a9 <getcallerpcs+0x71>
      break;
    pcs[i] = ebp[1];     // saved %eip
80105165:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105168:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
8010516f:	8b 45 0c             	mov    0xc(%ebp),%eax
80105172:	01 c2                	add    %eax,%edx
80105174:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105177:	8b 40 04             	mov    0x4(%eax),%eax
8010517a:	89 02                	mov    %eax,(%edx)
    ebp = (uint*)ebp[0]; // saved %ebp
8010517c:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010517f:	8b 00                	mov    (%eax),%eax
80105181:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(i = 0; i < 10; i++){
80105184:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
80105188:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
8010518c:	7e c2                	jle    80105150 <getcallerpcs+0x18>
  }
  for(; i < 10; i++)
8010518e:	eb 19                	jmp    801051a9 <getcallerpcs+0x71>
    pcs[i] = 0;
80105190:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105193:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
8010519a:	8b 45 0c             	mov    0xc(%ebp),%eax
8010519d:	01 d0                	add    %edx,%eax
8010519f:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  for(; i < 10; i++)
801051a5:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
801051a9:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
801051ad:	7e e1                	jle    80105190 <getcallerpcs+0x58>
}
801051af:	90                   	nop
801051b0:	90                   	nop
801051b1:	c9                   	leave
801051b2:	c3                   	ret

801051b3 <holding>:

// Check whether this cpu is holding the lock.
int
holding(struct spinlock *lock)
{
801051b3:	55                   	push   %ebp
801051b4:	89 e5                	mov    %esp,%ebp
  return lock->locked && lock->cpu == cpu;
801051b6:	8b 45 08             	mov    0x8(%ebp),%eax
801051b9:	8b 00                	mov    (%eax),%eax
801051bb:	85 c0                	test   %eax,%eax
801051bd:	74 17                	je     801051d6 <holding+0x23>
801051bf:	8b 45 08             	mov    0x8(%ebp),%eax
801051c2:	8b 50 08             	mov    0x8(%eax),%edx
801051c5:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801051cb:	39 c2                	cmp    %eax,%edx
801051cd:	75 07                	jne    801051d6 <holding+0x23>
801051cf:	b8 01 00 00 00       	mov    $0x1,%eax
801051d4:	eb 05                	jmp    801051db <holding+0x28>
801051d6:	b8 00 00 00 00       	mov    $0x0,%eax
}
801051db:	5d                   	pop    %ebp
801051dc:	c3                   	ret

801051dd <pushcli>:
// it takes two popcli to undo two pushcli.  Also, if interrupts
// are off, then pushcli, popcli leaves them off.

void
pushcli(void)
{
801051dd:	55                   	push   %ebp
801051de:	89 e5                	mov    %esp,%ebp
801051e0:	83 ec 10             	sub    $0x10,%esp
  int eflags;
  
  eflags = readeflags();
801051e3:	e8 3d fe ff ff       	call   80105025 <readeflags>
801051e8:	89 45 fc             	mov    %eax,-0x4(%ebp)
  cli();
801051eb:	e8 45 fe ff ff       	call   80105035 <cli>
  if(cpu->ncli++ == 0)
801051f0:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
801051f7:	8b 82 ac 00 00 00    	mov    0xac(%edx),%eax
801051fd:	8d 48 01             	lea    0x1(%eax),%ecx
80105200:	89 8a ac 00 00 00    	mov    %ecx,0xac(%edx)
80105206:	85 c0                	test   %eax,%eax
80105208:	75 15                	jne    8010521f <pushcli+0x42>
    cpu->intena = eflags & FL_IF;
8010520a:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80105210:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105213:	81 e2 00 02 00 00    	and    $0x200,%edx
80105219:	89 90 b0 00 00 00    	mov    %edx,0xb0(%eax)
}
8010521f:	90                   	nop
80105220:	c9                   	leave
80105221:	c3                   	ret

80105222 <popcli>:

void
popcli(void)
{
80105222:	55                   	push   %ebp
80105223:	89 e5                	mov    %esp,%ebp
80105225:	83 ec 08             	sub    $0x8,%esp
  if(readeflags()&FL_IF)
80105228:	e8 f8 fd ff ff       	call   80105025 <readeflags>
8010522d:	25 00 02 00 00       	and    $0x200,%eax
80105232:	85 c0                	test   %eax,%eax
80105234:	74 0d                	je     80105243 <popcli+0x21>
    panic("popcli - interruptible");
80105236:	83 ec 0c             	sub    $0xc,%esp
80105239:	68 53 8c 10 80       	push   $0x80108c53
8010523e:	e8 36 b3 ff ff       	call   80100579 <panic>
  if(--cpu->ncli < 0)
80105243:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80105249:	8b 90 ac 00 00 00    	mov    0xac(%eax),%edx
8010524f:	83 ea 01             	sub    $0x1,%edx
80105252:	89 90 ac 00 00 00    	mov    %edx,0xac(%eax)
80105258:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
8010525e:	85 c0                	test   %eax,%eax
80105260:	79 0d                	jns    8010526f <popcli+0x4d>
    panic("popcli");
80105262:	83 ec 0c             	sub    $0xc,%esp
80105265:	68 6a 8c 10 80       	push   $0x80108c6a
8010526a:	e8 0a b3 ff ff       	call   80100579 <panic>
  if(cpu->ncli == 0 && cpu->intena)
8010526f:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80105275:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
8010527b:	85 c0                	test   %eax,%eax
8010527d:	75 15                	jne    80105294 <popcli+0x72>
8010527f:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80105285:	8b 80 b0 00 00 00    	mov    0xb0(%eax),%eax
8010528b:	85 c0                	test   %eax,%eax
8010528d:	74 05                	je     80105294 <popcli+0x72>
    sti();
8010528f:	e8 a8 fd ff ff       	call   8010503c <sti>
}
80105294:	90                   	nop
80105295:	c9                   	leave
80105296:	c3                   	ret

80105297 <stosb>:
{
80105297:	55                   	push   %ebp
80105298:	89 e5                	mov    %esp,%ebp
8010529a:	57                   	push   %edi
8010529b:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
8010529c:	8b 4d 08             	mov    0x8(%ebp),%ecx
8010529f:	8b 55 10             	mov    0x10(%ebp),%edx
801052a2:	8b 45 0c             	mov    0xc(%ebp),%eax
801052a5:	89 cb                	mov    %ecx,%ebx
801052a7:	89 df                	mov    %ebx,%edi
801052a9:	89 d1                	mov    %edx,%ecx
801052ab:	fc                   	cld
801052ac:	f3 aa                	rep stos %al,%es:(%edi)
801052ae:	89 ca                	mov    %ecx,%edx
801052b0:	89 fb                	mov    %edi,%ebx
801052b2:	89 5d 08             	mov    %ebx,0x8(%ebp)
801052b5:	89 55 10             	mov    %edx,0x10(%ebp)
}
801052b8:	90                   	nop
801052b9:	5b                   	pop    %ebx
801052ba:	5f                   	pop    %edi
801052bb:	5d                   	pop    %ebp
801052bc:	c3                   	ret

801052bd <stosl>:
{
801052bd:	55                   	push   %ebp
801052be:	89 e5                	mov    %esp,%ebp
801052c0:	57                   	push   %edi
801052c1:	53                   	push   %ebx
  asm volatile("cld; rep stosl" :
801052c2:	8b 4d 08             	mov    0x8(%ebp),%ecx
801052c5:	8b 55 10             	mov    0x10(%ebp),%edx
801052c8:	8b 45 0c             	mov    0xc(%ebp),%eax
801052cb:	89 cb                	mov    %ecx,%ebx
801052cd:	89 df                	mov    %ebx,%edi
801052cf:	89 d1                	mov    %edx,%ecx
801052d1:	fc                   	cld
801052d2:	f3 ab                	rep stos %eax,%es:(%edi)
801052d4:	89 ca                	mov    %ecx,%edx
801052d6:	89 fb                	mov    %edi,%ebx
801052d8:	89 5d 08             	mov    %ebx,0x8(%ebp)
801052db:	89 55 10             	mov    %edx,0x10(%ebp)
}
801052de:	90                   	nop
801052df:	5b                   	pop    %ebx
801052e0:	5f                   	pop    %edi
801052e1:	5d                   	pop    %ebp
801052e2:	c3                   	ret

801052e3 <memset>:
#include "types.h"
#include "x86.h"

void*
memset(void *dst, int c, uint n)
{
801052e3:	55                   	push   %ebp
801052e4:	89 e5                	mov    %esp,%ebp
  if ((int)dst%4 == 0 && n%4 == 0){
801052e6:	8b 45 08             	mov    0x8(%ebp),%eax
801052e9:	83 e0 03             	and    $0x3,%eax
801052ec:	85 c0                	test   %eax,%eax
801052ee:	75 43                	jne    80105333 <memset+0x50>
801052f0:	8b 45 10             	mov    0x10(%ebp),%eax
801052f3:	83 e0 03             	and    $0x3,%eax
801052f6:	85 c0                	test   %eax,%eax
801052f8:	75 39                	jne    80105333 <memset+0x50>
    c &= 0xFF;
801052fa:	81 65 0c ff 00 00 00 	andl   $0xff,0xc(%ebp)
    stosl(dst, (c<<24)|(c<<16)|(c<<8)|c, n/4);
80105301:	8b 45 10             	mov    0x10(%ebp),%eax
80105304:	c1 e8 02             	shr    $0x2,%eax
80105307:	89 c1                	mov    %eax,%ecx
80105309:	8b 45 0c             	mov    0xc(%ebp),%eax
8010530c:	c1 e0 18             	shl    $0x18,%eax
8010530f:	89 c2                	mov    %eax,%edx
80105311:	8b 45 0c             	mov    0xc(%ebp),%eax
80105314:	c1 e0 10             	shl    $0x10,%eax
80105317:	09 c2                	or     %eax,%edx
80105319:	8b 45 0c             	mov    0xc(%ebp),%eax
8010531c:	c1 e0 08             	shl    $0x8,%eax
8010531f:	09 d0                	or     %edx,%eax
80105321:	0b 45 0c             	or     0xc(%ebp),%eax
80105324:	51                   	push   %ecx
80105325:	50                   	push   %eax
80105326:	ff 75 08             	push   0x8(%ebp)
80105329:	e8 8f ff ff ff       	call   801052bd <stosl>
8010532e:	83 c4 0c             	add    $0xc,%esp
80105331:	eb 12                	jmp    80105345 <memset+0x62>
  } else
    stosb(dst, c, n);
80105333:	8b 45 10             	mov    0x10(%ebp),%eax
80105336:	50                   	push   %eax
80105337:	ff 75 0c             	push   0xc(%ebp)
8010533a:	ff 75 08             	push   0x8(%ebp)
8010533d:	e8 55 ff ff ff       	call   80105297 <stosb>
80105342:	83 c4 0c             	add    $0xc,%esp
  return dst;
80105345:	8b 45 08             	mov    0x8(%ebp),%eax
}
80105348:	c9                   	leave
80105349:	c3                   	ret

8010534a <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
8010534a:	55                   	push   %ebp
8010534b:	89 e5                	mov    %esp,%ebp
8010534d:	83 ec 10             	sub    $0x10,%esp
  const uchar *s1, *s2;
  
  s1 = v1;
80105350:	8b 45 08             	mov    0x8(%ebp),%eax
80105353:	89 45 fc             	mov    %eax,-0x4(%ebp)
  s2 = v2;
80105356:	8b 45 0c             	mov    0xc(%ebp),%eax
80105359:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0){
8010535c:	eb 2e                	jmp    8010538c <memcmp+0x42>
    if(*s1 != *s2)
8010535e:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105361:	0f b6 10             	movzbl (%eax),%edx
80105364:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105367:	0f b6 00             	movzbl (%eax),%eax
8010536a:	38 c2                	cmp    %al,%dl
8010536c:	74 16                	je     80105384 <memcmp+0x3a>
      return *s1 - *s2;
8010536e:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105371:	0f b6 00             	movzbl (%eax),%eax
80105374:	0f b6 d0             	movzbl %al,%edx
80105377:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010537a:	0f b6 00             	movzbl (%eax),%eax
8010537d:	0f b6 c0             	movzbl %al,%eax
80105380:	29 c2                	sub    %eax,%edx
80105382:	eb 1a                	jmp    8010539e <memcmp+0x54>
    s1++, s2++;
80105384:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80105388:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
  while(n-- > 0){
8010538c:	8b 45 10             	mov    0x10(%ebp),%eax
8010538f:	8d 50 ff             	lea    -0x1(%eax),%edx
80105392:	89 55 10             	mov    %edx,0x10(%ebp)
80105395:	85 c0                	test   %eax,%eax
80105397:	75 c5                	jne    8010535e <memcmp+0x14>
  }

  return 0;
80105399:	ba 00 00 00 00       	mov    $0x0,%edx
}
8010539e:	89 d0                	mov    %edx,%eax
801053a0:	c9                   	leave
801053a1:	c3                   	ret

801053a2 <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
801053a2:	55                   	push   %ebp
801053a3:	89 e5                	mov    %esp,%ebp
801053a5:	83 ec 10             	sub    $0x10,%esp
  const char *s;
  char *d;

  s = src;
801053a8:	8b 45 0c             	mov    0xc(%ebp),%eax
801053ab:	89 45 fc             	mov    %eax,-0x4(%ebp)
  d = dst;
801053ae:	8b 45 08             	mov    0x8(%ebp),%eax
801053b1:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if(s < d && s + n > d){
801053b4:	8b 45 fc             	mov    -0x4(%ebp),%eax
801053b7:	3b 45 f8             	cmp    -0x8(%ebp),%eax
801053ba:	73 54                	jae    80105410 <memmove+0x6e>
801053bc:	8b 55 fc             	mov    -0x4(%ebp),%edx
801053bf:	8b 45 10             	mov    0x10(%ebp),%eax
801053c2:	01 d0                	add    %edx,%eax
801053c4:	39 45 f8             	cmp    %eax,-0x8(%ebp)
801053c7:	73 47                	jae    80105410 <memmove+0x6e>
    s += n;
801053c9:	8b 45 10             	mov    0x10(%ebp),%eax
801053cc:	01 45 fc             	add    %eax,-0x4(%ebp)
    d += n;
801053cf:	8b 45 10             	mov    0x10(%ebp),%eax
801053d2:	01 45 f8             	add    %eax,-0x8(%ebp)
    while(n-- > 0)
801053d5:	eb 13                	jmp    801053ea <memmove+0x48>
      *--d = *--s;
801053d7:	83 6d fc 01          	subl   $0x1,-0x4(%ebp)
801053db:	83 6d f8 01          	subl   $0x1,-0x8(%ebp)
801053df:	8b 45 fc             	mov    -0x4(%ebp),%eax
801053e2:	0f b6 10             	movzbl (%eax),%edx
801053e5:	8b 45 f8             	mov    -0x8(%ebp),%eax
801053e8:	88 10                	mov    %dl,(%eax)
    while(n-- > 0)
801053ea:	8b 45 10             	mov    0x10(%ebp),%eax
801053ed:	8d 50 ff             	lea    -0x1(%eax),%edx
801053f0:	89 55 10             	mov    %edx,0x10(%ebp)
801053f3:	85 c0                	test   %eax,%eax
801053f5:	75 e0                	jne    801053d7 <memmove+0x35>
  if(s < d && s + n > d){
801053f7:	eb 24                	jmp    8010541d <memmove+0x7b>
  } else
    while(n-- > 0)
      *d++ = *s++;
801053f9:	8b 55 fc             	mov    -0x4(%ebp),%edx
801053fc:	8d 42 01             	lea    0x1(%edx),%eax
801053ff:	89 45 fc             	mov    %eax,-0x4(%ebp)
80105402:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105405:	8d 48 01             	lea    0x1(%eax),%ecx
80105408:	89 4d f8             	mov    %ecx,-0x8(%ebp)
8010540b:	0f b6 12             	movzbl (%edx),%edx
8010540e:	88 10                	mov    %dl,(%eax)
    while(n-- > 0)
80105410:	8b 45 10             	mov    0x10(%ebp),%eax
80105413:	8d 50 ff             	lea    -0x1(%eax),%edx
80105416:	89 55 10             	mov    %edx,0x10(%ebp)
80105419:	85 c0                	test   %eax,%eax
8010541b:	75 dc                	jne    801053f9 <memmove+0x57>

  return dst;
8010541d:	8b 45 08             	mov    0x8(%ebp),%eax
}
80105420:	c9                   	leave
80105421:	c3                   	ret

80105422 <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
80105422:	55                   	push   %ebp
80105423:	89 e5                	mov    %esp,%ebp
  return memmove(dst, src, n);
80105425:	ff 75 10             	push   0x10(%ebp)
80105428:	ff 75 0c             	push   0xc(%ebp)
8010542b:	ff 75 08             	push   0x8(%ebp)
8010542e:	e8 6f ff ff ff       	call   801053a2 <memmove>
80105433:	83 c4 0c             	add    $0xc,%esp
}
80105436:	c9                   	leave
80105437:	c3                   	ret

80105438 <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
80105438:	55                   	push   %ebp
80105439:	89 e5                	mov    %esp,%ebp
  while(n > 0 && *p && *p == *q)
8010543b:	eb 0c                	jmp    80105449 <strncmp+0x11>
    n--, p++, q++;
8010543d:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
80105441:	83 45 08 01          	addl   $0x1,0x8(%ebp)
80105445:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
  while(n > 0 && *p && *p == *q)
80105449:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
8010544d:	74 1a                	je     80105469 <strncmp+0x31>
8010544f:	8b 45 08             	mov    0x8(%ebp),%eax
80105452:	0f b6 00             	movzbl (%eax),%eax
80105455:	84 c0                	test   %al,%al
80105457:	74 10                	je     80105469 <strncmp+0x31>
80105459:	8b 45 08             	mov    0x8(%ebp),%eax
8010545c:	0f b6 10             	movzbl (%eax),%edx
8010545f:	8b 45 0c             	mov    0xc(%ebp),%eax
80105462:	0f b6 00             	movzbl (%eax),%eax
80105465:	38 c2                	cmp    %al,%dl
80105467:	74 d4                	je     8010543d <strncmp+0x5>
  if(n == 0)
80105469:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
8010546d:	75 07                	jne    80105476 <strncmp+0x3e>
    return 0;
8010546f:	ba 00 00 00 00       	mov    $0x0,%edx
80105474:	eb 14                	jmp    8010548a <strncmp+0x52>
  return (uchar)*p - (uchar)*q;
80105476:	8b 45 08             	mov    0x8(%ebp),%eax
80105479:	0f b6 00             	movzbl (%eax),%eax
8010547c:	0f b6 d0             	movzbl %al,%edx
8010547f:	8b 45 0c             	mov    0xc(%ebp),%eax
80105482:	0f b6 00             	movzbl (%eax),%eax
80105485:	0f b6 c0             	movzbl %al,%eax
80105488:	29 c2                	sub    %eax,%edx
}
8010548a:	89 d0                	mov    %edx,%eax
8010548c:	5d                   	pop    %ebp
8010548d:	c3                   	ret

8010548e <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
8010548e:	55                   	push   %ebp
8010548f:	89 e5                	mov    %esp,%ebp
80105491:	83 ec 10             	sub    $0x10,%esp
  char *os;
  
  os = s;
80105494:	8b 45 08             	mov    0x8(%ebp),%eax
80105497:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while(n-- > 0 && (*s++ = *t++) != 0)
8010549a:	90                   	nop
8010549b:	8b 45 10             	mov    0x10(%ebp),%eax
8010549e:	8d 50 ff             	lea    -0x1(%eax),%edx
801054a1:	89 55 10             	mov    %edx,0x10(%ebp)
801054a4:	85 c0                	test   %eax,%eax
801054a6:	7e 2c                	jle    801054d4 <strncpy+0x46>
801054a8:	8b 55 0c             	mov    0xc(%ebp),%edx
801054ab:	8d 42 01             	lea    0x1(%edx),%eax
801054ae:	89 45 0c             	mov    %eax,0xc(%ebp)
801054b1:	8b 45 08             	mov    0x8(%ebp),%eax
801054b4:	8d 48 01             	lea    0x1(%eax),%ecx
801054b7:	89 4d 08             	mov    %ecx,0x8(%ebp)
801054ba:	0f b6 12             	movzbl (%edx),%edx
801054bd:	88 10                	mov    %dl,(%eax)
801054bf:	0f b6 00             	movzbl (%eax),%eax
801054c2:	84 c0                	test   %al,%al
801054c4:	75 d5                	jne    8010549b <strncpy+0xd>
    ;
  while(n-- > 0)
801054c6:	eb 0c                	jmp    801054d4 <strncpy+0x46>
    *s++ = 0;
801054c8:	8b 45 08             	mov    0x8(%ebp),%eax
801054cb:	8d 50 01             	lea    0x1(%eax),%edx
801054ce:	89 55 08             	mov    %edx,0x8(%ebp)
801054d1:	c6 00 00             	movb   $0x0,(%eax)
  while(n-- > 0)
801054d4:	8b 45 10             	mov    0x10(%ebp),%eax
801054d7:	8d 50 ff             	lea    -0x1(%eax),%edx
801054da:	89 55 10             	mov    %edx,0x10(%ebp)
801054dd:	85 c0                	test   %eax,%eax
801054df:	7f e7                	jg     801054c8 <strncpy+0x3a>
  return os;
801054e1:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
801054e4:	c9                   	leave
801054e5:	c3                   	ret

801054e6 <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
801054e6:	55                   	push   %ebp
801054e7:	89 e5                	mov    %esp,%ebp
801054e9:	83 ec 10             	sub    $0x10,%esp
  char *os;
  
  os = s;
801054ec:	8b 45 08             	mov    0x8(%ebp),%eax
801054ef:	89 45 fc             	mov    %eax,-0x4(%ebp)
  if(n <= 0)
801054f2:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801054f6:	7f 05                	jg     801054fd <safestrcpy+0x17>
    return os;
801054f8:	8b 45 fc             	mov    -0x4(%ebp),%eax
801054fb:	eb 32                	jmp    8010552f <safestrcpy+0x49>
  while(--n > 0 && (*s++ = *t++) != 0)
801054fd:	90                   	nop
801054fe:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
80105502:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105506:	7e 1e                	jle    80105526 <safestrcpy+0x40>
80105508:	8b 55 0c             	mov    0xc(%ebp),%edx
8010550b:	8d 42 01             	lea    0x1(%edx),%eax
8010550e:	89 45 0c             	mov    %eax,0xc(%ebp)
80105511:	8b 45 08             	mov    0x8(%ebp),%eax
80105514:	8d 48 01             	lea    0x1(%eax),%ecx
80105517:	89 4d 08             	mov    %ecx,0x8(%ebp)
8010551a:	0f b6 12             	movzbl (%edx),%edx
8010551d:	88 10                	mov    %dl,(%eax)
8010551f:	0f b6 00             	movzbl (%eax),%eax
80105522:	84 c0                	test   %al,%al
80105524:	75 d8                	jne    801054fe <safestrcpy+0x18>
    ;
  *s = 0;
80105526:	8b 45 08             	mov    0x8(%ebp),%eax
80105529:	c6 00 00             	movb   $0x0,(%eax)
  return os;
8010552c:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
8010552f:	c9                   	leave
80105530:	c3                   	ret

80105531 <strlen>:

int
strlen(const char *s)
{
80105531:	55                   	push   %ebp
80105532:	89 e5                	mov    %esp,%ebp
80105534:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
80105537:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
8010553e:	eb 04                	jmp    80105544 <strlen+0x13>
80105540:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80105544:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105547:	8b 45 08             	mov    0x8(%ebp),%eax
8010554a:	01 d0                	add    %edx,%eax
8010554c:	0f b6 00             	movzbl (%eax),%eax
8010554f:	84 c0                	test   %al,%al
80105551:	75 ed                	jne    80105540 <strlen+0xf>
    ;
  return n;
80105553:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80105556:	c9                   	leave
80105557:	c3                   	ret

80105558 <swtch>:
# Save current register context in old
# and then load register context from new.

.globl swtch
swtch:
  movl 4(%esp), %eax
80105558:	8b 44 24 04          	mov    0x4(%esp),%eax
  movl 8(%esp), %edx
8010555c:	8b 54 24 08          	mov    0x8(%esp),%edx

  # Save old callee-save registers
  pushl %ebp
80105560:	55                   	push   %ebp
  pushl %ebx
80105561:	53                   	push   %ebx
  pushl %esi
80105562:	56                   	push   %esi
  pushl %edi
80105563:	57                   	push   %edi

  # Switch stacks
  movl %esp, (%eax)
80105564:	89 20                	mov    %esp,(%eax)
  movl %edx, %esp
80105566:	89 d4                	mov    %edx,%esp

  # Load new callee-save registers
  popl %edi
80105568:	5f                   	pop    %edi
  popl %esi
80105569:	5e                   	pop    %esi
  popl %ebx
8010556a:	5b                   	pop    %ebx
  popl %ebp
8010556b:	5d                   	pop    %ebp
  ret
8010556c:	c3                   	ret

8010556d <fetchint>:
// to a saved program counter, and then the first argument.

// Fetch the int at addr from the current process.
int
fetchint(uint addr, int *ip)
{
8010556d:	55                   	push   %ebp
8010556e:	89 e5                	mov    %esp,%ebp
  if(addr >= proc->sz || addr+4 > proc->sz)
80105570:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105576:	8b 00                	mov    (%eax),%eax
80105578:	39 45 08             	cmp    %eax,0x8(%ebp)
8010557b:	73 12                	jae    8010558f <fetchint+0x22>
8010557d:	8b 45 08             	mov    0x8(%ebp),%eax
80105580:	8d 50 04             	lea    0x4(%eax),%edx
80105583:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105589:	8b 00                	mov    (%eax),%eax
8010558b:	39 d0                	cmp    %edx,%eax
8010558d:	73 07                	jae    80105596 <fetchint+0x29>
    return -1;
8010558f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105594:	eb 0f                	jmp    801055a5 <fetchint+0x38>
  *ip = *(int*)(addr);
80105596:	8b 45 08             	mov    0x8(%ebp),%eax
80105599:	8b 10                	mov    (%eax),%edx
8010559b:	8b 45 0c             	mov    0xc(%ebp),%eax
8010559e:	89 10                	mov    %edx,(%eax)
  return 0;
801055a0:	b8 00 00 00 00       	mov    $0x0,%eax
}
801055a5:	5d                   	pop    %ebp
801055a6:	c3                   	ret

801055a7 <fetchstr>:
// Fetch the nul-terminated string at addr from the current process.
// Doesn't actually copy the string - just sets *pp to point at it.
// Returns length of string, not including nul.
int
fetchstr(uint addr, char **pp)
{
801055a7:	55                   	push   %ebp
801055a8:	89 e5                	mov    %esp,%ebp
801055aa:	83 ec 10             	sub    $0x10,%esp
  char *s, *ep;

  if(addr >= proc->sz)
801055ad:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801055b3:	8b 00                	mov    (%eax),%eax
801055b5:	39 45 08             	cmp    %eax,0x8(%ebp)
801055b8:	72 07                	jb     801055c1 <fetchstr+0x1a>
    return -1;
801055ba:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801055bf:	eb 44                	jmp    80105605 <fetchstr+0x5e>
  *pp = (char*)addr;
801055c1:	8b 55 08             	mov    0x8(%ebp),%edx
801055c4:	8b 45 0c             	mov    0xc(%ebp),%eax
801055c7:	89 10                	mov    %edx,(%eax)
  ep = (char*)proc->sz;
801055c9:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801055cf:	8b 00                	mov    (%eax),%eax
801055d1:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(s = *pp; s < ep; s++)
801055d4:	8b 45 0c             	mov    0xc(%ebp),%eax
801055d7:	8b 00                	mov    (%eax),%eax
801055d9:	89 45 fc             	mov    %eax,-0x4(%ebp)
801055dc:	eb 1a                	jmp    801055f8 <fetchstr+0x51>
    if(*s == 0)
801055de:	8b 45 fc             	mov    -0x4(%ebp),%eax
801055e1:	0f b6 00             	movzbl (%eax),%eax
801055e4:	84 c0                	test   %al,%al
801055e6:	75 0c                	jne    801055f4 <fetchstr+0x4d>
      return s - *pp;
801055e8:	8b 45 0c             	mov    0xc(%ebp),%eax
801055eb:	8b 10                	mov    (%eax),%edx
801055ed:	8b 45 fc             	mov    -0x4(%ebp),%eax
801055f0:	29 d0                	sub    %edx,%eax
801055f2:	eb 11                	jmp    80105605 <fetchstr+0x5e>
  for(s = *pp; s < ep; s++)
801055f4:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
801055f8:	8b 45 fc             	mov    -0x4(%ebp),%eax
801055fb:	3b 45 f8             	cmp    -0x8(%ebp),%eax
801055fe:	72 de                	jb     801055de <fetchstr+0x37>
  return -1;
80105600:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105605:	c9                   	leave
80105606:	c3                   	ret

80105607 <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
80105607:	55                   	push   %ebp
80105608:	89 e5                	mov    %esp,%ebp
  return fetchint(proc->tf->esp + 4 + 4*n, ip);
8010560a:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105610:	8b 40 18             	mov    0x18(%eax),%eax
80105613:	8b 40 44             	mov    0x44(%eax),%eax
80105616:	8b 55 08             	mov    0x8(%ebp),%edx
80105619:	c1 e2 02             	shl    $0x2,%edx
8010561c:	01 d0                	add    %edx,%eax
8010561e:	83 c0 04             	add    $0x4,%eax
80105621:	ff 75 0c             	push   0xc(%ebp)
80105624:	50                   	push   %eax
80105625:	e8 43 ff ff ff       	call   8010556d <fetchint>
8010562a:	83 c4 08             	add    $0x8,%esp
}
8010562d:	c9                   	leave
8010562e:	c3                   	ret

8010562f <argptr>:
// Fetch the nth word-sized system call argument as a pointer
// to a block of memory of size n bytes.  Check that the pointer
// lies within the process address space.
int
argptr(int n, char **pp, int size)
{
8010562f:	55                   	push   %ebp
80105630:	89 e5                	mov    %esp,%ebp
80105632:	83 ec 10             	sub    $0x10,%esp
  int i;
  
  if(argint(n, &i) < 0)
80105635:	8d 45 fc             	lea    -0x4(%ebp),%eax
80105638:	50                   	push   %eax
80105639:	ff 75 08             	push   0x8(%ebp)
8010563c:	e8 c6 ff ff ff       	call   80105607 <argint>
80105641:	83 c4 08             	add    $0x8,%esp
80105644:	85 c0                	test   %eax,%eax
80105646:	79 07                	jns    8010564f <argptr+0x20>
    return -1;
80105648:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010564d:	eb 3b                	jmp    8010568a <argptr+0x5b>
  if((uint)i >= proc->sz || (uint)i+size > proc->sz)
8010564f:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105655:	8b 00                	mov    (%eax),%eax
80105657:	8b 55 fc             	mov    -0x4(%ebp),%edx
8010565a:	39 c2                	cmp    %eax,%edx
8010565c:	73 16                	jae    80105674 <argptr+0x45>
8010565e:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105661:	89 c2                	mov    %eax,%edx
80105663:	8b 45 10             	mov    0x10(%ebp),%eax
80105666:	01 c2                	add    %eax,%edx
80105668:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010566e:	8b 00                	mov    (%eax),%eax
80105670:	39 d0                	cmp    %edx,%eax
80105672:	73 07                	jae    8010567b <argptr+0x4c>
    return -1;
80105674:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105679:	eb 0f                	jmp    8010568a <argptr+0x5b>
  *pp = (char*)i;
8010567b:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010567e:	89 c2                	mov    %eax,%edx
80105680:	8b 45 0c             	mov    0xc(%ebp),%eax
80105683:	89 10                	mov    %edx,(%eax)
  return 0;
80105685:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010568a:	c9                   	leave
8010568b:	c3                   	ret

8010568c <argstr>:
// Check that the pointer is valid and the string is nul-terminated.
// (There is no shared writable memory, so the string can't change
// between this check and being used by the kernel.)
int
argstr(int n, char **pp)
{
8010568c:	55                   	push   %ebp
8010568d:	89 e5                	mov    %esp,%ebp
8010568f:	83 ec 10             	sub    $0x10,%esp
  int addr;
  if(argint(n, &addr) < 0)
80105692:	8d 45 fc             	lea    -0x4(%ebp),%eax
80105695:	50                   	push   %eax
80105696:	ff 75 08             	push   0x8(%ebp)
80105699:	e8 69 ff ff ff       	call   80105607 <argint>
8010569e:	83 c4 08             	add    $0x8,%esp
801056a1:	85 c0                	test   %eax,%eax
801056a3:	79 07                	jns    801056ac <argstr+0x20>
    return -1;
801056a5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801056aa:	eb 0f                	jmp    801056bb <argstr+0x2f>
  return fetchstr(addr, pp);
801056ac:	8b 45 fc             	mov    -0x4(%ebp),%eax
801056af:	ff 75 0c             	push   0xc(%ebp)
801056b2:	50                   	push   %eax
801056b3:	e8 ef fe ff ff       	call   801055a7 <fetchstr>
801056b8:	83 c4 08             	add    $0x8,%esp
}
801056bb:	c9                   	leave
801056bc:	c3                   	ret

801056bd <syscall>:
[SYS_shmdel] sys_shmdel,                                // CS 3320 project 2
};

void
syscall(void)
{
801056bd:	55                   	push   %ebp
801056be:	89 e5                	mov    %esp,%ebp
801056c0:	83 ec 18             	sub    $0x18,%esp
  int num;

  num = proc->tf->eax;
801056c3:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801056c9:	8b 40 18             	mov    0x18(%eax),%eax
801056cc:	8b 40 1c             	mov    0x1c(%eax),%eax
801056cf:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
801056d2:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801056d6:	7e 32                	jle    8010570a <syscall+0x4d>
801056d8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801056db:	83 f8 1a             	cmp    $0x1a,%eax
801056de:	77 2a                	ja     8010570a <syscall+0x4d>
801056e0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801056e3:	8b 04 85 40 b0 10 80 	mov    -0x7fef4fc0(,%eax,4),%eax
801056ea:	85 c0                	test   %eax,%eax
801056ec:	74 1c                	je     8010570a <syscall+0x4d>
    proc->tf->eax = syscalls[num]();
801056ee:	8b 45 f4             	mov    -0xc(%ebp),%eax
801056f1:	8b 04 85 40 b0 10 80 	mov    -0x7fef4fc0(,%eax,4),%eax
801056f8:	ff d0                	call   *%eax
801056fa:	89 c2                	mov    %eax,%edx
801056fc:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105702:	8b 40 18             	mov    0x18(%eax),%eax
80105705:	89 50 1c             	mov    %edx,0x1c(%eax)
80105708:	eb 35                	jmp    8010573f <syscall+0x82>
  } else {
    cprintf("%d %s: unknown sys call %d\n",
            proc->pid, proc->name, num);
8010570a:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105710:	8d 50 6c             	lea    0x6c(%eax),%edx
80105713:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
    cprintf("%d %s: unknown sys call %d\n",
80105719:	8b 40 10             	mov    0x10(%eax),%eax
8010571c:	ff 75 f4             	push   -0xc(%ebp)
8010571f:	52                   	push   %edx
80105720:	50                   	push   %eax
80105721:	68 71 8c 10 80       	push   $0x80108c71
80105726:	e8 99 ac ff ff       	call   801003c4 <cprintf>
8010572b:	83 c4 10             	add    $0x10,%esp
    proc->tf->eax = -1;
8010572e:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105734:	8b 40 18             	mov    0x18(%eax),%eax
80105737:	c7 40 1c ff ff ff ff 	movl   $0xffffffff,0x1c(%eax)
  }
}
8010573e:	90                   	nop
8010573f:	90                   	nop
80105740:	c9                   	leave
80105741:	c3                   	ret

80105742 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
80105742:	55                   	push   %ebp
80105743:	89 e5                	mov    %esp,%ebp
80105745:	83 ec 18             	sub    $0x18,%esp
  int fd;
  struct file *f;

  if(argint(n, &fd) < 0)
80105748:	83 ec 08             	sub    $0x8,%esp
8010574b:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010574e:	50                   	push   %eax
8010574f:	ff 75 08             	push   0x8(%ebp)
80105752:	e8 b0 fe ff ff       	call   80105607 <argint>
80105757:	83 c4 10             	add    $0x10,%esp
8010575a:	85 c0                	test   %eax,%eax
8010575c:	79 07                	jns    80105765 <argfd+0x23>
    return -1;
8010575e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105763:	eb 50                	jmp    801057b5 <argfd+0x73>
  if(fd < 0 || fd >= NOFILE || (f=proc->ofile[fd]) == 0)
80105765:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105768:	85 c0                	test   %eax,%eax
8010576a:	78 21                	js     8010578d <argfd+0x4b>
8010576c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010576f:	83 f8 0f             	cmp    $0xf,%eax
80105772:	7f 19                	jg     8010578d <argfd+0x4b>
80105774:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010577a:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010577d:	83 c2 08             	add    $0x8,%edx
80105780:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80105784:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105787:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010578b:	75 07                	jne    80105794 <argfd+0x52>
    return -1;
8010578d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105792:	eb 21                	jmp    801057b5 <argfd+0x73>
  if(pfd)
80105794:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80105798:	74 08                	je     801057a2 <argfd+0x60>
    *pfd = fd;
8010579a:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010579d:	8b 45 0c             	mov    0xc(%ebp),%eax
801057a0:	89 10                	mov    %edx,(%eax)
  if(pf)
801057a2:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801057a6:	74 08                	je     801057b0 <argfd+0x6e>
    *pf = f;
801057a8:	8b 45 10             	mov    0x10(%ebp),%eax
801057ab:	8b 55 f4             	mov    -0xc(%ebp),%edx
801057ae:	89 10                	mov    %edx,(%eax)
  return 0;
801057b0:	b8 00 00 00 00       	mov    $0x0,%eax
}
801057b5:	c9                   	leave
801057b6:	c3                   	ret

801057b7 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
801057b7:	55                   	push   %ebp
801057b8:	89 e5                	mov    %esp,%ebp
801057ba:	83 ec 10             	sub    $0x10,%esp
  int fd;

  for(fd = 0; fd < NOFILE; fd++){
801057bd:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
801057c4:	eb 30                	jmp    801057f6 <fdalloc+0x3f>
    if(proc->ofile[fd] == 0){
801057c6:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801057cc:	8b 55 fc             	mov    -0x4(%ebp),%edx
801057cf:	83 c2 08             	add    $0x8,%edx
801057d2:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
801057d6:	85 c0                	test   %eax,%eax
801057d8:	75 18                	jne    801057f2 <fdalloc+0x3b>
      proc->ofile[fd] = f;
801057da:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801057e0:	8b 55 fc             	mov    -0x4(%ebp),%edx
801057e3:	8d 4a 08             	lea    0x8(%edx),%ecx
801057e6:	8b 55 08             	mov    0x8(%ebp),%edx
801057e9:	89 54 88 08          	mov    %edx,0x8(%eax,%ecx,4)
      return fd;
801057ed:	8b 45 fc             	mov    -0x4(%ebp),%eax
801057f0:	eb 0f                	jmp    80105801 <fdalloc+0x4a>
  for(fd = 0; fd < NOFILE; fd++){
801057f2:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
801057f6:	83 7d fc 0f          	cmpl   $0xf,-0x4(%ebp)
801057fa:	7e ca                	jle    801057c6 <fdalloc+0xf>
    }
  }
  return -1;
801057fc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105801:	c9                   	leave
80105802:	c3                   	ret

80105803 <sys_dup>:

int
sys_dup(void)
{
80105803:	55                   	push   %ebp
80105804:	89 e5                	mov    %esp,%ebp
80105806:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  int fd;
  
  if(argfd(0, 0, &f) < 0)
80105809:	83 ec 04             	sub    $0x4,%esp
8010580c:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010580f:	50                   	push   %eax
80105810:	6a 00                	push   $0x0
80105812:	6a 00                	push   $0x0
80105814:	e8 29 ff ff ff       	call   80105742 <argfd>
80105819:	83 c4 10             	add    $0x10,%esp
8010581c:	85 c0                	test   %eax,%eax
8010581e:	79 07                	jns    80105827 <sys_dup+0x24>
    return -1;
80105820:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105825:	eb 31                	jmp    80105858 <sys_dup+0x55>
  if((fd=fdalloc(f)) < 0)
80105827:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010582a:	83 ec 0c             	sub    $0xc,%esp
8010582d:	50                   	push   %eax
8010582e:	e8 84 ff ff ff       	call   801057b7 <fdalloc>
80105833:	83 c4 10             	add    $0x10,%esp
80105836:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105839:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010583d:	79 07                	jns    80105846 <sys_dup+0x43>
    return -1;
8010583f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105844:	eb 12                	jmp    80105858 <sys_dup+0x55>
  filedup(f);
80105846:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105849:	83 ec 0c             	sub    $0xc,%esp
8010584c:	50                   	push   %eax
8010584d:	e8 df b7 ff ff       	call   80101031 <filedup>
80105852:	83 c4 10             	add    $0x10,%esp
  return fd;
80105855:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80105858:	c9                   	leave
80105859:	c3                   	ret

8010585a <sys_read>:

int
sys_read(void)
{
8010585a:	55                   	push   %ebp
8010585b:	89 e5                	mov    %esp,%ebp
8010585d:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
80105860:	83 ec 04             	sub    $0x4,%esp
80105863:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105866:	50                   	push   %eax
80105867:	6a 00                	push   $0x0
80105869:	6a 00                	push   $0x0
8010586b:	e8 d2 fe ff ff       	call   80105742 <argfd>
80105870:	83 c4 10             	add    $0x10,%esp
80105873:	85 c0                	test   %eax,%eax
80105875:	78 2e                	js     801058a5 <sys_read+0x4b>
80105877:	83 ec 08             	sub    $0x8,%esp
8010587a:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010587d:	50                   	push   %eax
8010587e:	6a 02                	push   $0x2
80105880:	e8 82 fd ff ff       	call   80105607 <argint>
80105885:	83 c4 10             	add    $0x10,%esp
80105888:	85 c0                	test   %eax,%eax
8010588a:	78 19                	js     801058a5 <sys_read+0x4b>
8010588c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010588f:	83 ec 04             	sub    $0x4,%esp
80105892:	50                   	push   %eax
80105893:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105896:	50                   	push   %eax
80105897:	6a 01                	push   $0x1
80105899:	e8 91 fd ff ff       	call   8010562f <argptr>
8010589e:	83 c4 10             	add    $0x10,%esp
801058a1:	85 c0                	test   %eax,%eax
801058a3:	79 07                	jns    801058ac <sys_read+0x52>
    return -1;
801058a5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801058aa:	eb 17                	jmp    801058c3 <sys_read+0x69>
  return fileread(f, p, n);
801058ac:	8b 4d f0             	mov    -0x10(%ebp),%ecx
801058af:	8b 55 ec             	mov    -0x14(%ebp),%edx
801058b2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801058b5:	83 ec 04             	sub    $0x4,%esp
801058b8:	51                   	push   %ecx
801058b9:	52                   	push   %edx
801058ba:	50                   	push   %eax
801058bb:	e8 01 b9 ff ff       	call   801011c1 <fileread>
801058c0:	83 c4 10             	add    $0x10,%esp
}
801058c3:	c9                   	leave
801058c4:	c3                   	ret

801058c5 <sys_write>:

int
sys_write(void)
{
801058c5:	55                   	push   %ebp
801058c6:	89 e5                	mov    %esp,%ebp
801058c8:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
801058cb:	83 ec 04             	sub    $0x4,%esp
801058ce:	8d 45 f4             	lea    -0xc(%ebp),%eax
801058d1:	50                   	push   %eax
801058d2:	6a 00                	push   $0x0
801058d4:	6a 00                	push   $0x0
801058d6:	e8 67 fe ff ff       	call   80105742 <argfd>
801058db:	83 c4 10             	add    $0x10,%esp
801058de:	85 c0                	test   %eax,%eax
801058e0:	78 2e                	js     80105910 <sys_write+0x4b>
801058e2:	83 ec 08             	sub    $0x8,%esp
801058e5:	8d 45 f0             	lea    -0x10(%ebp),%eax
801058e8:	50                   	push   %eax
801058e9:	6a 02                	push   $0x2
801058eb:	e8 17 fd ff ff       	call   80105607 <argint>
801058f0:	83 c4 10             	add    $0x10,%esp
801058f3:	85 c0                	test   %eax,%eax
801058f5:	78 19                	js     80105910 <sys_write+0x4b>
801058f7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801058fa:	83 ec 04             	sub    $0x4,%esp
801058fd:	50                   	push   %eax
801058fe:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105901:	50                   	push   %eax
80105902:	6a 01                	push   $0x1
80105904:	e8 26 fd ff ff       	call   8010562f <argptr>
80105909:	83 c4 10             	add    $0x10,%esp
8010590c:	85 c0                	test   %eax,%eax
8010590e:	79 07                	jns    80105917 <sys_write+0x52>
    return -1;
80105910:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105915:	eb 17                	jmp    8010592e <sys_write+0x69>
  return filewrite(f, p, n);
80105917:	8b 4d f0             	mov    -0x10(%ebp),%ecx
8010591a:	8b 55 ec             	mov    -0x14(%ebp),%edx
8010591d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105920:	83 ec 04             	sub    $0x4,%esp
80105923:	51                   	push   %ecx
80105924:	52                   	push   %edx
80105925:	50                   	push   %eax
80105926:	e8 4e b9 ff ff       	call   80101279 <filewrite>
8010592b:	83 c4 10             	add    $0x10,%esp
}
8010592e:	c9                   	leave
8010592f:	c3                   	ret

80105930 <sys_close>:

int
sys_close(void)
{
80105930:	55                   	push   %ebp
80105931:	89 e5                	mov    %esp,%ebp
80105933:	83 ec 18             	sub    $0x18,%esp
  int fd;
  struct file *f;
  
  if(argfd(0, &fd, &f) < 0)
80105936:	83 ec 04             	sub    $0x4,%esp
80105939:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010593c:	50                   	push   %eax
8010593d:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105940:	50                   	push   %eax
80105941:	6a 00                	push   $0x0
80105943:	e8 fa fd ff ff       	call   80105742 <argfd>
80105948:	83 c4 10             	add    $0x10,%esp
8010594b:	85 c0                	test   %eax,%eax
8010594d:	79 07                	jns    80105956 <sys_close+0x26>
    return -1;
8010594f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105954:	eb 28                	jmp    8010597e <sys_close+0x4e>
  proc->ofile[fd] = 0;
80105956:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010595c:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010595f:	83 c2 08             	add    $0x8,%edx
80105962:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
80105969:	00 
  fileclose(f);
8010596a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010596d:	83 ec 0c             	sub    $0xc,%esp
80105970:	50                   	push   %eax
80105971:	e8 0c b7 ff ff       	call   80101082 <fileclose>
80105976:	83 c4 10             	add    $0x10,%esp
  return 0;
80105979:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010597e:	c9                   	leave
8010597f:	c3                   	ret

80105980 <sys_fstat>:

int
sys_fstat(void)
{
80105980:	55                   	push   %ebp
80105981:	89 e5                	mov    %esp,%ebp
80105983:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  struct stat *st;
  
  if(argfd(0, 0, &f) < 0 || argptr(1, (void*)&st, sizeof(*st)) < 0)
80105986:	83 ec 04             	sub    $0x4,%esp
80105989:	8d 45 f4             	lea    -0xc(%ebp),%eax
8010598c:	50                   	push   %eax
8010598d:	6a 00                	push   $0x0
8010598f:	6a 00                	push   $0x0
80105991:	e8 ac fd ff ff       	call   80105742 <argfd>
80105996:	83 c4 10             	add    $0x10,%esp
80105999:	85 c0                	test   %eax,%eax
8010599b:	78 17                	js     801059b4 <sys_fstat+0x34>
8010599d:	83 ec 04             	sub    $0x4,%esp
801059a0:	6a 14                	push   $0x14
801059a2:	8d 45 f0             	lea    -0x10(%ebp),%eax
801059a5:	50                   	push   %eax
801059a6:	6a 01                	push   $0x1
801059a8:	e8 82 fc ff ff       	call   8010562f <argptr>
801059ad:	83 c4 10             	add    $0x10,%esp
801059b0:	85 c0                	test   %eax,%eax
801059b2:	79 07                	jns    801059bb <sys_fstat+0x3b>
    return -1;
801059b4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801059b9:	eb 13                	jmp    801059ce <sys_fstat+0x4e>
  return filestat(f, st);
801059bb:	8b 55 f0             	mov    -0x10(%ebp),%edx
801059be:	8b 45 f4             	mov    -0xc(%ebp),%eax
801059c1:	83 ec 08             	sub    $0x8,%esp
801059c4:	52                   	push   %edx
801059c5:	50                   	push   %eax
801059c6:	e8 9f b7 ff ff       	call   8010116a <filestat>
801059cb:	83 c4 10             	add    $0x10,%esp
}
801059ce:	c9                   	leave
801059cf:	c3                   	ret

801059d0 <sys_link>:

// Create the path new as a link to the same inode as old.
int
sys_link(void)
{
801059d0:	55                   	push   %ebp
801059d1:	89 e5                	mov    %esp,%ebp
801059d3:	83 ec 28             	sub    $0x28,%esp
  char name[DIRSIZ], *new, *old;
  struct inode *dp, *ip;

  if(argstr(0, &old) < 0 || argstr(1, &new) < 0)
801059d6:	83 ec 08             	sub    $0x8,%esp
801059d9:	8d 45 d8             	lea    -0x28(%ebp),%eax
801059dc:	50                   	push   %eax
801059dd:	6a 00                	push   $0x0
801059df:	e8 a8 fc ff ff       	call   8010568c <argstr>
801059e4:	83 c4 10             	add    $0x10,%esp
801059e7:	85 c0                	test   %eax,%eax
801059e9:	78 15                	js     80105a00 <sys_link+0x30>
801059eb:	83 ec 08             	sub    $0x8,%esp
801059ee:	8d 45 dc             	lea    -0x24(%ebp),%eax
801059f1:	50                   	push   %eax
801059f2:	6a 01                	push   $0x1
801059f4:	e8 93 fc ff ff       	call   8010568c <argstr>
801059f9:	83 c4 10             	add    $0x10,%esp
801059fc:	85 c0                	test   %eax,%eax
801059fe:	79 0a                	jns    80105a0a <sys_link+0x3a>
    return -1;
80105a00:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105a05:	e9 68 01 00 00       	jmp    80105b72 <sys_link+0x1a2>

  begin_op();
80105a0a:	e8 61 db ff ff       	call   80103570 <begin_op>
  if((ip = namei(old)) == 0){
80105a0f:	8b 45 d8             	mov    -0x28(%ebp),%eax
80105a12:	83 ec 0c             	sub    $0xc,%esp
80105a15:	50                   	push   %eax
80105a16:	e8 1f cb ff ff       	call   8010253a <namei>
80105a1b:	83 c4 10             	add    $0x10,%esp
80105a1e:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105a21:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105a25:	75 0f                	jne    80105a36 <sys_link+0x66>
    end_op();
80105a27:	e8 d0 db ff ff       	call   801035fc <end_op>
    return -1;
80105a2c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105a31:	e9 3c 01 00 00       	jmp    80105b72 <sys_link+0x1a2>
  }

  ilock(ip);
80105a36:	83 ec 0c             	sub    $0xc,%esp
80105a39:	ff 75 f4             	push   -0xc(%ebp)
80105a3c:	e8 48 bf ff ff       	call   80101989 <ilock>
80105a41:	83 c4 10             	add    $0x10,%esp
  if(ip->type == T_DIR){
80105a44:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105a47:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80105a4b:	66 83 f8 01          	cmp    $0x1,%ax
80105a4f:	75 1d                	jne    80105a6e <sys_link+0x9e>
    iunlockput(ip);
80105a51:	83 ec 0c             	sub    $0xc,%esp
80105a54:	ff 75 f4             	push   -0xc(%ebp)
80105a57:	e8 ed c1 ff ff       	call   80101c49 <iunlockput>
80105a5c:	83 c4 10             	add    $0x10,%esp
    end_op();
80105a5f:	e8 98 db ff ff       	call   801035fc <end_op>
    return -1;
80105a64:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105a69:	e9 04 01 00 00       	jmp    80105b72 <sys_link+0x1a2>
  }

  ip->nlink++;
80105a6e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105a71:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80105a75:	83 c0 01             	add    $0x1,%eax
80105a78:	89 c2                	mov    %eax,%edx
80105a7a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105a7d:	66 89 50 16          	mov    %dx,0x16(%eax)
  iupdate(ip);
80105a81:	83 ec 0c             	sub    $0xc,%esp
80105a84:	ff 75 f4             	push   -0xc(%ebp)
80105a87:	e8 23 bd ff ff       	call   801017af <iupdate>
80105a8c:	83 c4 10             	add    $0x10,%esp
  iunlock(ip);
80105a8f:	83 ec 0c             	sub    $0xc,%esp
80105a92:	ff 75 f4             	push   -0xc(%ebp)
80105a95:	e8 4d c0 ff ff       	call   80101ae7 <iunlock>
80105a9a:	83 c4 10             	add    $0x10,%esp

  if((dp = nameiparent(new, name)) == 0)
80105a9d:	8b 45 dc             	mov    -0x24(%ebp),%eax
80105aa0:	83 ec 08             	sub    $0x8,%esp
80105aa3:	8d 55 e2             	lea    -0x1e(%ebp),%edx
80105aa6:	52                   	push   %edx
80105aa7:	50                   	push   %eax
80105aa8:	e8 a9 ca ff ff       	call   80102556 <nameiparent>
80105aad:	83 c4 10             	add    $0x10,%esp
80105ab0:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105ab3:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105ab7:	74 71                	je     80105b2a <sys_link+0x15a>
    goto bad;
  ilock(dp);
80105ab9:	83 ec 0c             	sub    $0xc,%esp
80105abc:	ff 75 f0             	push   -0x10(%ebp)
80105abf:	e8 c5 be ff ff       	call   80101989 <ilock>
80105ac4:	83 c4 10             	add    $0x10,%esp
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
80105ac7:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105aca:	8b 10                	mov    (%eax),%edx
80105acc:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105acf:	8b 00                	mov    (%eax),%eax
80105ad1:	39 c2                	cmp    %eax,%edx
80105ad3:	75 1d                	jne    80105af2 <sys_link+0x122>
80105ad5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105ad8:	8b 40 04             	mov    0x4(%eax),%eax
80105adb:	83 ec 04             	sub    $0x4,%esp
80105ade:	50                   	push   %eax
80105adf:	8d 45 e2             	lea    -0x1e(%ebp),%eax
80105ae2:	50                   	push   %eax
80105ae3:	ff 75 f0             	push   -0x10(%ebp)
80105ae6:	e8 b7 c7 ff ff       	call   801022a2 <dirlink>
80105aeb:	83 c4 10             	add    $0x10,%esp
80105aee:	85 c0                	test   %eax,%eax
80105af0:	79 10                	jns    80105b02 <sys_link+0x132>
    iunlockput(dp);
80105af2:	83 ec 0c             	sub    $0xc,%esp
80105af5:	ff 75 f0             	push   -0x10(%ebp)
80105af8:	e8 4c c1 ff ff       	call   80101c49 <iunlockput>
80105afd:	83 c4 10             	add    $0x10,%esp
    goto bad;
80105b00:	eb 29                	jmp    80105b2b <sys_link+0x15b>
  }
  iunlockput(dp);
80105b02:	83 ec 0c             	sub    $0xc,%esp
80105b05:	ff 75 f0             	push   -0x10(%ebp)
80105b08:	e8 3c c1 ff ff       	call   80101c49 <iunlockput>
80105b0d:	83 c4 10             	add    $0x10,%esp
  iput(ip);
80105b10:	83 ec 0c             	sub    $0xc,%esp
80105b13:	ff 75 f4             	push   -0xc(%ebp)
80105b16:	e8 3e c0 ff ff       	call   80101b59 <iput>
80105b1b:	83 c4 10             	add    $0x10,%esp

  end_op();
80105b1e:	e8 d9 da ff ff       	call   801035fc <end_op>

  return 0;
80105b23:	b8 00 00 00 00       	mov    $0x0,%eax
80105b28:	eb 48                	jmp    80105b72 <sys_link+0x1a2>
    goto bad;
80105b2a:	90                   	nop

bad:
  ilock(ip);
80105b2b:	83 ec 0c             	sub    $0xc,%esp
80105b2e:	ff 75 f4             	push   -0xc(%ebp)
80105b31:	e8 53 be ff ff       	call   80101989 <ilock>
80105b36:	83 c4 10             	add    $0x10,%esp
  ip->nlink--;
80105b39:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105b3c:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80105b40:	83 e8 01             	sub    $0x1,%eax
80105b43:	89 c2                	mov    %eax,%edx
80105b45:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105b48:	66 89 50 16          	mov    %dx,0x16(%eax)
  iupdate(ip);
80105b4c:	83 ec 0c             	sub    $0xc,%esp
80105b4f:	ff 75 f4             	push   -0xc(%ebp)
80105b52:	e8 58 bc ff ff       	call   801017af <iupdate>
80105b57:	83 c4 10             	add    $0x10,%esp
  iunlockput(ip);
80105b5a:	83 ec 0c             	sub    $0xc,%esp
80105b5d:	ff 75 f4             	push   -0xc(%ebp)
80105b60:	e8 e4 c0 ff ff       	call   80101c49 <iunlockput>
80105b65:	83 c4 10             	add    $0x10,%esp
  end_op();
80105b68:	e8 8f da ff ff       	call   801035fc <end_op>
  return -1;
80105b6d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105b72:	c9                   	leave
80105b73:	c3                   	ret

80105b74 <isdirempty>:

// Is the directory dp empty except for "." and ".." ?
static int
isdirempty(struct inode *dp)
{
80105b74:	55                   	push   %ebp
80105b75:	89 e5                	mov    %esp,%ebp
80105b77:	83 ec 28             	sub    $0x28,%esp
  int off;
  struct dirent de;

  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
80105b7a:	c7 45 f4 20 00 00 00 	movl   $0x20,-0xc(%ebp)
80105b81:	eb 40                	jmp    80105bc3 <isdirempty+0x4f>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80105b83:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105b86:	6a 10                	push   $0x10
80105b88:	50                   	push   %eax
80105b89:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80105b8c:	50                   	push   %eax
80105b8d:	ff 75 08             	push   0x8(%ebp)
80105b90:	e8 5d c3 ff ff       	call   80101ef2 <readi>
80105b95:	83 c4 10             	add    $0x10,%esp
80105b98:	83 f8 10             	cmp    $0x10,%eax
80105b9b:	74 0d                	je     80105baa <isdirempty+0x36>
      panic("isdirempty: readi");
80105b9d:	83 ec 0c             	sub    $0xc,%esp
80105ba0:	68 8d 8c 10 80       	push   $0x80108c8d
80105ba5:	e8 cf a9 ff ff       	call   80100579 <panic>
    if(de.inum != 0)
80105baa:	0f b7 45 e4          	movzwl -0x1c(%ebp),%eax
80105bae:	66 85 c0             	test   %ax,%ax
80105bb1:	74 07                	je     80105bba <isdirempty+0x46>
      return 0;
80105bb3:	b8 00 00 00 00       	mov    $0x0,%eax
80105bb8:	eb 1b                	jmp    80105bd5 <isdirempty+0x61>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
80105bba:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105bbd:	83 c0 10             	add    $0x10,%eax
80105bc0:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105bc3:	8b 45 08             	mov    0x8(%ebp),%eax
80105bc6:	8b 40 18             	mov    0x18(%eax),%eax
80105bc9:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105bcc:	39 c2                	cmp    %eax,%edx
80105bce:	72 b3                	jb     80105b83 <isdirempty+0xf>
  }
  return 1;
80105bd0:	b8 01 00 00 00       	mov    $0x1,%eax
}
80105bd5:	c9                   	leave
80105bd6:	c3                   	ret

80105bd7 <sys_unlink>:

//PAGEBREAK!
int
sys_unlink(void)
{
80105bd7:	55                   	push   %ebp
80105bd8:	89 e5                	mov    %esp,%ebp
80105bda:	83 ec 38             	sub    $0x38,%esp
  struct inode *ip, *dp;
  struct dirent de;
  char name[DIRSIZ], *path;
  uint off;

  if(argstr(0, &path) < 0)
80105bdd:	83 ec 08             	sub    $0x8,%esp
80105be0:	8d 45 cc             	lea    -0x34(%ebp),%eax
80105be3:	50                   	push   %eax
80105be4:	6a 00                	push   $0x0
80105be6:	e8 a1 fa ff ff       	call   8010568c <argstr>
80105beb:	83 c4 10             	add    $0x10,%esp
80105bee:	85 c0                	test   %eax,%eax
80105bf0:	79 0a                	jns    80105bfc <sys_unlink+0x25>
    return -1;
80105bf2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105bf7:	e9 bf 01 00 00       	jmp    80105dbb <sys_unlink+0x1e4>

  begin_op();
80105bfc:	e8 6f d9 ff ff       	call   80103570 <begin_op>
  if((dp = nameiparent(path, name)) == 0){
80105c01:	8b 45 cc             	mov    -0x34(%ebp),%eax
80105c04:	83 ec 08             	sub    $0x8,%esp
80105c07:	8d 55 d2             	lea    -0x2e(%ebp),%edx
80105c0a:	52                   	push   %edx
80105c0b:	50                   	push   %eax
80105c0c:	e8 45 c9 ff ff       	call   80102556 <nameiparent>
80105c11:	83 c4 10             	add    $0x10,%esp
80105c14:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105c17:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105c1b:	75 0f                	jne    80105c2c <sys_unlink+0x55>
    end_op();
80105c1d:	e8 da d9 ff ff       	call   801035fc <end_op>
    return -1;
80105c22:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105c27:	e9 8f 01 00 00       	jmp    80105dbb <sys_unlink+0x1e4>
  }

  ilock(dp);
80105c2c:	83 ec 0c             	sub    $0xc,%esp
80105c2f:	ff 75 f4             	push   -0xc(%ebp)
80105c32:	e8 52 bd ff ff       	call   80101989 <ilock>
80105c37:	83 c4 10             	add    $0x10,%esp

  // Cannot unlink "." or "..".
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
80105c3a:	83 ec 08             	sub    $0x8,%esp
80105c3d:	68 9f 8c 10 80       	push   $0x80108c9f
80105c42:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80105c45:	50                   	push   %eax
80105c46:	e8 82 c5 ff ff       	call   801021cd <namecmp>
80105c4b:	83 c4 10             	add    $0x10,%esp
80105c4e:	85 c0                	test   %eax,%eax
80105c50:	0f 84 49 01 00 00    	je     80105d9f <sys_unlink+0x1c8>
80105c56:	83 ec 08             	sub    $0x8,%esp
80105c59:	68 a1 8c 10 80       	push   $0x80108ca1
80105c5e:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80105c61:	50                   	push   %eax
80105c62:	e8 66 c5 ff ff       	call   801021cd <namecmp>
80105c67:	83 c4 10             	add    $0x10,%esp
80105c6a:	85 c0                	test   %eax,%eax
80105c6c:	0f 84 2d 01 00 00    	je     80105d9f <sys_unlink+0x1c8>
    goto bad;

  if((ip = dirlookup(dp, name, &off)) == 0)
80105c72:	83 ec 04             	sub    $0x4,%esp
80105c75:	8d 45 c8             	lea    -0x38(%ebp),%eax
80105c78:	50                   	push   %eax
80105c79:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80105c7c:	50                   	push   %eax
80105c7d:	ff 75 f4             	push   -0xc(%ebp)
80105c80:	e8 63 c5 ff ff       	call   801021e8 <dirlookup>
80105c85:	83 c4 10             	add    $0x10,%esp
80105c88:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105c8b:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105c8f:	0f 84 0d 01 00 00    	je     80105da2 <sys_unlink+0x1cb>
    goto bad;
  ilock(ip);
80105c95:	83 ec 0c             	sub    $0xc,%esp
80105c98:	ff 75 f0             	push   -0x10(%ebp)
80105c9b:	e8 e9 bc ff ff       	call   80101989 <ilock>
80105ca0:	83 c4 10             	add    $0x10,%esp

  if(ip->nlink < 1)
80105ca3:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105ca6:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80105caa:	66 85 c0             	test   %ax,%ax
80105cad:	7f 0d                	jg     80105cbc <sys_unlink+0xe5>
    panic("unlink: nlink < 1");
80105caf:	83 ec 0c             	sub    $0xc,%esp
80105cb2:	68 a4 8c 10 80       	push   $0x80108ca4
80105cb7:	e8 bd a8 ff ff       	call   80100579 <panic>
  if(ip->type == T_DIR && !isdirempty(ip)){
80105cbc:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105cbf:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80105cc3:	66 83 f8 01          	cmp    $0x1,%ax
80105cc7:	75 25                	jne    80105cee <sys_unlink+0x117>
80105cc9:	83 ec 0c             	sub    $0xc,%esp
80105ccc:	ff 75 f0             	push   -0x10(%ebp)
80105ccf:	e8 a0 fe ff ff       	call   80105b74 <isdirempty>
80105cd4:	83 c4 10             	add    $0x10,%esp
80105cd7:	85 c0                	test   %eax,%eax
80105cd9:	75 13                	jne    80105cee <sys_unlink+0x117>
    iunlockput(ip);
80105cdb:	83 ec 0c             	sub    $0xc,%esp
80105cde:	ff 75 f0             	push   -0x10(%ebp)
80105ce1:	e8 63 bf ff ff       	call   80101c49 <iunlockput>
80105ce6:	83 c4 10             	add    $0x10,%esp
    goto bad;
80105ce9:	e9 b5 00 00 00       	jmp    80105da3 <sys_unlink+0x1cc>
  }

  memset(&de, 0, sizeof(de));
80105cee:	83 ec 04             	sub    $0x4,%esp
80105cf1:	6a 10                	push   $0x10
80105cf3:	6a 00                	push   $0x0
80105cf5:	8d 45 e0             	lea    -0x20(%ebp),%eax
80105cf8:	50                   	push   %eax
80105cf9:	e8 e5 f5 ff ff       	call   801052e3 <memset>
80105cfe:	83 c4 10             	add    $0x10,%esp
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80105d01:	8b 45 c8             	mov    -0x38(%ebp),%eax
80105d04:	6a 10                	push   $0x10
80105d06:	50                   	push   %eax
80105d07:	8d 45 e0             	lea    -0x20(%ebp),%eax
80105d0a:	50                   	push   %eax
80105d0b:	ff 75 f4             	push   -0xc(%ebp)
80105d0e:	e8 34 c3 ff ff       	call   80102047 <writei>
80105d13:	83 c4 10             	add    $0x10,%esp
80105d16:	83 f8 10             	cmp    $0x10,%eax
80105d19:	74 0d                	je     80105d28 <sys_unlink+0x151>
    panic("unlink: writei");
80105d1b:	83 ec 0c             	sub    $0xc,%esp
80105d1e:	68 b6 8c 10 80       	push   $0x80108cb6
80105d23:	e8 51 a8 ff ff       	call   80100579 <panic>
  if(ip->type == T_DIR){
80105d28:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105d2b:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80105d2f:	66 83 f8 01          	cmp    $0x1,%ax
80105d33:	75 21                	jne    80105d56 <sys_unlink+0x17f>
    dp->nlink--;
80105d35:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105d38:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80105d3c:	83 e8 01             	sub    $0x1,%eax
80105d3f:	89 c2                	mov    %eax,%edx
80105d41:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105d44:	66 89 50 16          	mov    %dx,0x16(%eax)
    iupdate(dp);
80105d48:	83 ec 0c             	sub    $0xc,%esp
80105d4b:	ff 75 f4             	push   -0xc(%ebp)
80105d4e:	e8 5c ba ff ff       	call   801017af <iupdate>
80105d53:	83 c4 10             	add    $0x10,%esp
  }
  iunlockput(dp);
80105d56:	83 ec 0c             	sub    $0xc,%esp
80105d59:	ff 75 f4             	push   -0xc(%ebp)
80105d5c:	e8 e8 be ff ff       	call   80101c49 <iunlockput>
80105d61:	83 c4 10             	add    $0x10,%esp

  ip->nlink--;
80105d64:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105d67:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80105d6b:	83 e8 01             	sub    $0x1,%eax
80105d6e:	89 c2                	mov    %eax,%edx
80105d70:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105d73:	66 89 50 16          	mov    %dx,0x16(%eax)
  iupdate(ip);
80105d77:	83 ec 0c             	sub    $0xc,%esp
80105d7a:	ff 75 f0             	push   -0x10(%ebp)
80105d7d:	e8 2d ba ff ff       	call   801017af <iupdate>
80105d82:	83 c4 10             	add    $0x10,%esp
  iunlockput(ip);
80105d85:	83 ec 0c             	sub    $0xc,%esp
80105d88:	ff 75 f0             	push   -0x10(%ebp)
80105d8b:	e8 b9 be ff ff       	call   80101c49 <iunlockput>
80105d90:	83 c4 10             	add    $0x10,%esp

  end_op();
80105d93:	e8 64 d8 ff ff       	call   801035fc <end_op>

  return 0;
80105d98:	b8 00 00 00 00       	mov    $0x0,%eax
80105d9d:	eb 1c                	jmp    80105dbb <sys_unlink+0x1e4>
    goto bad;
80105d9f:	90                   	nop
80105da0:	eb 01                	jmp    80105da3 <sys_unlink+0x1cc>
    goto bad;
80105da2:	90                   	nop

bad:
  iunlockput(dp);
80105da3:	83 ec 0c             	sub    $0xc,%esp
80105da6:	ff 75 f4             	push   -0xc(%ebp)
80105da9:	e8 9b be ff ff       	call   80101c49 <iunlockput>
80105dae:	83 c4 10             	add    $0x10,%esp
  end_op();
80105db1:	e8 46 d8 ff ff       	call   801035fc <end_op>
  return -1;
80105db6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105dbb:	c9                   	leave
80105dbc:	c3                   	ret

80105dbd <create>:

static struct inode*
create(char *path, short type, short major, short minor)
{
80105dbd:	55                   	push   %ebp
80105dbe:	89 e5                	mov    %esp,%ebp
80105dc0:	83 ec 38             	sub    $0x38,%esp
80105dc3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80105dc6:	8b 55 10             	mov    0x10(%ebp),%edx
80105dc9:	8b 45 14             	mov    0x14(%ebp),%eax
80105dcc:	66 89 4d d4          	mov    %cx,-0x2c(%ebp)
80105dd0:	66 89 55 d0          	mov    %dx,-0x30(%ebp)
80105dd4:	66 89 45 cc          	mov    %ax,-0x34(%ebp)
  uint off;
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
80105dd8:	83 ec 08             	sub    $0x8,%esp
80105ddb:	8d 45 de             	lea    -0x22(%ebp),%eax
80105dde:	50                   	push   %eax
80105ddf:	ff 75 08             	push   0x8(%ebp)
80105de2:	e8 6f c7 ff ff       	call   80102556 <nameiparent>
80105de7:	83 c4 10             	add    $0x10,%esp
80105dea:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105ded:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105df1:	75 0a                	jne    80105dfd <create+0x40>
    return 0;
80105df3:	b8 00 00 00 00       	mov    $0x0,%eax
80105df8:	e9 90 01 00 00       	jmp    80105f8d <create+0x1d0>
  ilock(dp);
80105dfd:	83 ec 0c             	sub    $0xc,%esp
80105e00:	ff 75 f4             	push   -0xc(%ebp)
80105e03:	e8 81 bb ff ff       	call   80101989 <ilock>
80105e08:	83 c4 10             	add    $0x10,%esp

  if((ip = dirlookup(dp, name, &off)) != 0){
80105e0b:	83 ec 04             	sub    $0x4,%esp
80105e0e:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105e11:	50                   	push   %eax
80105e12:	8d 45 de             	lea    -0x22(%ebp),%eax
80105e15:	50                   	push   %eax
80105e16:	ff 75 f4             	push   -0xc(%ebp)
80105e19:	e8 ca c3 ff ff       	call   801021e8 <dirlookup>
80105e1e:	83 c4 10             	add    $0x10,%esp
80105e21:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105e24:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105e28:	74 50                	je     80105e7a <create+0xbd>
    iunlockput(dp);
80105e2a:	83 ec 0c             	sub    $0xc,%esp
80105e2d:	ff 75 f4             	push   -0xc(%ebp)
80105e30:	e8 14 be ff ff       	call   80101c49 <iunlockput>
80105e35:	83 c4 10             	add    $0x10,%esp
    ilock(ip);
80105e38:	83 ec 0c             	sub    $0xc,%esp
80105e3b:	ff 75 f0             	push   -0x10(%ebp)
80105e3e:	e8 46 bb ff ff       	call   80101989 <ilock>
80105e43:	83 c4 10             	add    $0x10,%esp
    if(type == T_FILE && ip->type == T_FILE)
80105e46:	66 83 7d d4 02       	cmpw   $0x2,-0x2c(%ebp)
80105e4b:	75 15                	jne    80105e62 <create+0xa5>
80105e4d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105e50:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80105e54:	66 83 f8 02          	cmp    $0x2,%ax
80105e58:	75 08                	jne    80105e62 <create+0xa5>
      return ip;
80105e5a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105e5d:	e9 2b 01 00 00       	jmp    80105f8d <create+0x1d0>
    iunlockput(ip);
80105e62:	83 ec 0c             	sub    $0xc,%esp
80105e65:	ff 75 f0             	push   -0x10(%ebp)
80105e68:	e8 dc bd ff ff       	call   80101c49 <iunlockput>
80105e6d:	83 c4 10             	add    $0x10,%esp
    return 0;
80105e70:	b8 00 00 00 00       	mov    $0x0,%eax
80105e75:	e9 13 01 00 00       	jmp    80105f8d <create+0x1d0>
  }

  if((ip = ialloc(dp->dev, type)) == 0)
80105e7a:	0f bf 55 d4          	movswl -0x2c(%ebp),%edx
80105e7e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e81:	8b 00                	mov    (%eax),%eax
80105e83:	83 ec 08             	sub    $0x8,%esp
80105e86:	52                   	push   %edx
80105e87:	50                   	push   %eax
80105e88:	e8 4c b8 ff ff       	call   801016d9 <ialloc>
80105e8d:	83 c4 10             	add    $0x10,%esp
80105e90:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105e93:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105e97:	75 0d                	jne    80105ea6 <create+0xe9>
    panic("create: ialloc");
80105e99:	83 ec 0c             	sub    $0xc,%esp
80105e9c:	68 c5 8c 10 80       	push   $0x80108cc5
80105ea1:	e8 d3 a6 ff ff       	call   80100579 <panic>

  ilock(ip);
80105ea6:	83 ec 0c             	sub    $0xc,%esp
80105ea9:	ff 75 f0             	push   -0x10(%ebp)
80105eac:	e8 d8 ba ff ff       	call   80101989 <ilock>
80105eb1:	83 c4 10             	add    $0x10,%esp
  ip->major = major;
80105eb4:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105eb7:	0f b7 55 d0          	movzwl -0x30(%ebp),%edx
80105ebb:	66 89 50 12          	mov    %dx,0x12(%eax)
  ip->minor = minor;
80105ebf:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105ec2:	0f b7 55 cc          	movzwl -0x34(%ebp),%edx
80105ec6:	66 89 50 14          	mov    %dx,0x14(%eax)
  ip->nlink = 1;
80105eca:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105ecd:	66 c7 40 16 01 00    	movw   $0x1,0x16(%eax)
  iupdate(ip);
80105ed3:	83 ec 0c             	sub    $0xc,%esp
80105ed6:	ff 75 f0             	push   -0x10(%ebp)
80105ed9:	e8 d1 b8 ff ff       	call   801017af <iupdate>
80105ede:	83 c4 10             	add    $0x10,%esp

  if(type == T_DIR){  // Create . and .. entries.
80105ee1:	66 83 7d d4 01       	cmpw   $0x1,-0x2c(%ebp)
80105ee6:	75 6a                	jne    80105f52 <create+0x195>
    dp->nlink++;  // for ".."
80105ee8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105eeb:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80105eef:	83 c0 01             	add    $0x1,%eax
80105ef2:	89 c2                	mov    %eax,%edx
80105ef4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105ef7:	66 89 50 16          	mov    %dx,0x16(%eax)
    iupdate(dp);
80105efb:	83 ec 0c             	sub    $0xc,%esp
80105efe:	ff 75 f4             	push   -0xc(%ebp)
80105f01:	e8 a9 b8 ff ff       	call   801017af <iupdate>
80105f06:	83 c4 10             	add    $0x10,%esp
    // No ip->nlink++ for ".": avoid cyclic ref count.
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
80105f09:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105f0c:	8b 40 04             	mov    0x4(%eax),%eax
80105f0f:	83 ec 04             	sub    $0x4,%esp
80105f12:	50                   	push   %eax
80105f13:	68 9f 8c 10 80       	push   $0x80108c9f
80105f18:	ff 75 f0             	push   -0x10(%ebp)
80105f1b:	e8 82 c3 ff ff       	call   801022a2 <dirlink>
80105f20:	83 c4 10             	add    $0x10,%esp
80105f23:	85 c0                	test   %eax,%eax
80105f25:	78 1e                	js     80105f45 <create+0x188>
80105f27:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105f2a:	8b 40 04             	mov    0x4(%eax),%eax
80105f2d:	83 ec 04             	sub    $0x4,%esp
80105f30:	50                   	push   %eax
80105f31:	68 a1 8c 10 80       	push   $0x80108ca1
80105f36:	ff 75 f0             	push   -0x10(%ebp)
80105f39:	e8 64 c3 ff ff       	call   801022a2 <dirlink>
80105f3e:	83 c4 10             	add    $0x10,%esp
80105f41:	85 c0                	test   %eax,%eax
80105f43:	79 0d                	jns    80105f52 <create+0x195>
      panic("create dots");
80105f45:	83 ec 0c             	sub    $0xc,%esp
80105f48:	68 d4 8c 10 80       	push   $0x80108cd4
80105f4d:	e8 27 a6 ff ff       	call   80100579 <panic>
  }

  if(dirlink(dp, name, ip->inum) < 0)
80105f52:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105f55:	8b 40 04             	mov    0x4(%eax),%eax
80105f58:	83 ec 04             	sub    $0x4,%esp
80105f5b:	50                   	push   %eax
80105f5c:	8d 45 de             	lea    -0x22(%ebp),%eax
80105f5f:	50                   	push   %eax
80105f60:	ff 75 f4             	push   -0xc(%ebp)
80105f63:	e8 3a c3 ff ff       	call   801022a2 <dirlink>
80105f68:	83 c4 10             	add    $0x10,%esp
80105f6b:	85 c0                	test   %eax,%eax
80105f6d:	79 0d                	jns    80105f7c <create+0x1bf>
    panic("create: dirlink");
80105f6f:	83 ec 0c             	sub    $0xc,%esp
80105f72:	68 e0 8c 10 80       	push   $0x80108ce0
80105f77:	e8 fd a5 ff ff       	call   80100579 <panic>

  iunlockput(dp);
80105f7c:	83 ec 0c             	sub    $0xc,%esp
80105f7f:	ff 75 f4             	push   -0xc(%ebp)
80105f82:	e8 c2 bc ff ff       	call   80101c49 <iunlockput>
80105f87:	83 c4 10             	add    $0x10,%esp

  return ip;
80105f8a:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80105f8d:	c9                   	leave
80105f8e:	c3                   	ret

80105f8f <sys_open>:

int
sys_open(void)
{
80105f8f:	55                   	push   %ebp
80105f90:	89 e5                	mov    %esp,%ebp
80105f92:	83 ec 28             	sub    $0x28,%esp
  char *path;
  int fd, omode;
  struct file *f;
  struct inode *ip;

  if(argstr(0, &path) < 0 || argint(1, &omode) < 0)
80105f95:	83 ec 08             	sub    $0x8,%esp
80105f98:	8d 45 e8             	lea    -0x18(%ebp),%eax
80105f9b:	50                   	push   %eax
80105f9c:	6a 00                	push   $0x0
80105f9e:	e8 e9 f6 ff ff       	call   8010568c <argstr>
80105fa3:	83 c4 10             	add    $0x10,%esp
80105fa6:	85 c0                	test   %eax,%eax
80105fa8:	78 15                	js     80105fbf <sys_open+0x30>
80105faa:	83 ec 08             	sub    $0x8,%esp
80105fad:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80105fb0:	50                   	push   %eax
80105fb1:	6a 01                	push   $0x1
80105fb3:	e8 4f f6 ff ff       	call   80105607 <argint>
80105fb8:	83 c4 10             	add    $0x10,%esp
80105fbb:	85 c0                	test   %eax,%eax
80105fbd:	79 0a                	jns    80105fc9 <sys_open+0x3a>
    return -1;
80105fbf:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105fc4:	e9 61 01 00 00       	jmp    8010612a <sys_open+0x19b>

  begin_op();
80105fc9:	e8 a2 d5 ff ff       	call   80103570 <begin_op>

  if(omode & O_CREATE){
80105fce:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105fd1:	25 00 02 00 00       	and    $0x200,%eax
80105fd6:	85 c0                	test   %eax,%eax
80105fd8:	74 2a                	je     80106004 <sys_open+0x75>
    ip = create(path, T_FILE, 0, 0);
80105fda:	8b 45 e8             	mov    -0x18(%ebp),%eax
80105fdd:	6a 00                	push   $0x0
80105fdf:	6a 00                	push   $0x0
80105fe1:	6a 02                	push   $0x2
80105fe3:	50                   	push   %eax
80105fe4:	e8 d4 fd ff ff       	call   80105dbd <create>
80105fe9:	83 c4 10             	add    $0x10,%esp
80105fec:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(ip == 0){
80105fef:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105ff3:	75 75                	jne    8010606a <sys_open+0xdb>
      end_op();
80105ff5:	e8 02 d6 ff ff       	call   801035fc <end_op>
      return -1;
80105ffa:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105fff:	e9 26 01 00 00       	jmp    8010612a <sys_open+0x19b>
    }
  } else {
    if((ip = namei(path)) == 0){
80106004:	8b 45 e8             	mov    -0x18(%ebp),%eax
80106007:	83 ec 0c             	sub    $0xc,%esp
8010600a:	50                   	push   %eax
8010600b:	e8 2a c5 ff ff       	call   8010253a <namei>
80106010:	83 c4 10             	add    $0x10,%esp
80106013:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106016:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010601a:	75 0f                	jne    8010602b <sys_open+0x9c>
      end_op();
8010601c:	e8 db d5 ff ff       	call   801035fc <end_op>
      return -1;
80106021:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106026:	e9 ff 00 00 00       	jmp    8010612a <sys_open+0x19b>
    }
    ilock(ip);
8010602b:	83 ec 0c             	sub    $0xc,%esp
8010602e:	ff 75 f4             	push   -0xc(%ebp)
80106031:	e8 53 b9 ff ff       	call   80101989 <ilock>
80106036:	83 c4 10             	add    $0x10,%esp
    if(ip->type == T_DIR && omode != O_RDONLY){
80106039:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010603c:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80106040:	66 83 f8 01          	cmp    $0x1,%ax
80106044:	75 24                	jne    8010606a <sys_open+0xdb>
80106046:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106049:	85 c0                	test   %eax,%eax
8010604b:	74 1d                	je     8010606a <sys_open+0xdb>
      iunlockput(ip);
8010604d:	83 ec 0c             	sub    $0xc,%esp
80106050:	ff 75 f4             	push   -0xc(%ebp)
80106053:	e8 f1 bb ff ff       	call   80101c49 <iunlockput>
80106058:	83 c4 10             	add    $0x10,%esp
      end_op();
8010605b:	e8 9c d5 ff ff       	call   801035fc <end_op>
      return -1;
80106060:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106065:	e9 c0 00 00 00       	jmp    8010612a <sys_open+0x19b>
    }
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
8010606a:	e8 55 af ff ff       	call   80100fc4 <filealloc>
8010606f:	89 45 f0             	mov    %eax,-0x10(%ebp)
80106072:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80106076:	74 17                	je     8010608f <sys_open+0x100>
80106078:	83 ec 0c             	sub    $0xc,%esp
8010607b:	ff 75 f0             	push   -0x10(%ebp)
8010607e:	e8 34 f7 ff ff       	call   801057b7 <fdalloc>
80106083:	83 c4 10             	add    $0x10,%esp
80106086:	89 45 ec             	mov    %eax,-0x14(%ebp)
80106089:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
8010608d:	79 2e                	jns    801060bd <sys_open+0x12e>
    if(f)
8010608f:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80106093:	74 0e                	je     801060a3 <sys_open+0x114>
      fileclose(f);
80106095:	83 ec 0c             	sub    $0xc,%esp
80106098:	ff 75 f0             	push   -0x10(%ebp)
8010609b:	e8 e2 af ff ff       	call   80101082 <fileclose>
801060a0:	83 c4 10             	add    $0x10,%esp
    iunlockput(ip);
801060a3:	83 ec 0c             	sub    $0xc,%esp
801060a6:	ff 75 f4             	push   -0xc(%ebp)
801060a9:	e8 9b bb ff ff       	call   80101c49 <iunlockput>
801060ae:	83 c4 10             	add    $0x10,%esp
    end_op();
801060b1:	e8 46 d5 ff ff       	call   801035fc <end_op>
    return -1;
801060b6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801060bb:	eb 6d                	jmp    8010612a <sys_open+0x19b>
  }
  iunlock(ip);
801060bd:	83 ec 0c             	sub    $0xc,%esp
801060c0:	ff 75 f4             	push   -0xc(%ebp)
801060c3:	e8 1f ba ff ff       	call   80101ae7 <iunlock>
801060c8:	83 c4 10             	add    $0x10,%esp
  end_op();
801060cb:	e8 2c d5 ff ff       	call   801035fc <end_op>

  f->type = FD_INODE;
801060d0:	8b 45 f0             	mov    -0x10(%ebp),%eax
801060d3:	c7 00 02 00 00 00    	movl   $0x2,(%eax)
  f->ip = ip;
801060d9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801060dc:	8b 55 f4             	mov    -0xc(%ebp),%edx
801060df:	89 50 10             	mov    %edx,0x10(%eax)
  f->off = 0;
801060e2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801060e5:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
  f->readable = !(omode & O_WRONLY);
801060ec:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801060ef:	83 e0 01             	and    $0x1,%eax
801060f2:	85 c0                	test   %eax,%eax
801060f4:	0f 94 c0             	sete   %al
801060f7:	89 c2                	mov    %eax,%edx
801060f9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801060fc:	88 50 08             	mov    %dl,0x8(%eax)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
801060ff:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106102:	83 e0 01             	and    $0x1,%eax
80106105:	85 c0                	test   %eax,%eax
80106107:	75 0a                	jne    80106113 <sys_open+0x184>
80106109:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010610c:	83 e0 02             	and    $0x2,%eax
8010610f:	85 c0                	test   %eax,%eax
80106111:	74 07                	je     8010611a <sys_open+0x18b>
80106113:	b8 01 00 00 00       	mov    $0x1,%eax
80106118:	eb 05                	jmp    8010611f <sys_open+0x190>
8010611a:	b8 00 00 00 00       	mov    $0x0,%eax
8010611f:	89 c2                	mov    %eax,%edx
80106121:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106124:	88 50 09             	mov    %dl,0x9(%eax)
  return fd;
80106127:	8b 45 ec             	mov    -0x14(%ebp),%eax
}
8010612a:	c9                   	leave
8010612b:	c3                   	ret

8010612c <sys_mkdir>:

int
sys_mkdir(void)
{
8010612c:	55                   	push   %ebp
8010612d:	89 e5                	mov    %esp,%ebp
8010612f:	83 ec 18             	sub    $0x18,%esp
  char *path;
  struct inode *ip;

  begin_op();
80106132:	e8 39 d4 ff ff       	call   80103570 <begin_op>
  if(argstr(0, &path) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
80106137:	83 ec 08             	sub    $0x8,%esp
8010613a:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010613d:	50                   	push   %eax
8010613e:	6a 00                	push   $0x0
80106140:	e8 47 f5 ff ff       	call   8010568c <argstr>
80106145:	83 c4 10             	add    $0x10,%esp
80106148:	85 c0                	test   %eax,%eax
8010614a:	78 1b                	js     80106167 <sys_mkdir+0x3b>
8010614c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010614f:	6a 00                	push   $0x0
80106151:	6a 00                	push   $0x0
80106153:	6a 01                	push   $0x1
80106155:	50                   	push   %eax
80106156:	e8 62 fc ff ff       	call   80105dbd <create>
8010615b:	83 c4 10             	add    $0x10,%esp
8010615e:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106161:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106165:	75 0c                	jne    80106173 <sys_mkdir+0x47>
    end_op();
80106167:	e8 90 d4 ff ff       	call   801035fc <end_op>
    return -1;
8010616c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106171:	eb 18                	jmp    8010618b <sys_mkdir+0x5f>
  }
  iunlockput(ip);
80106173:	83 ec 0c             	sub    $0xc,%esp
80106176:	ff 75 f4             	push   -0xc(%ebp)
80106179:	e8 cb ba ff ff       	call   80101c49 <iunlockput>
8010617e:	83 c4 10             	add    $0x10,%esp
  end_op();
80106181:	e8 76 d4 ff ff       	call   801035fc <end_op>
  return 0;
80106186:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010618b:	c9                   	leave
8010618c:	c3                   	ret

8010618d <sys_mknod>:

int
sys_mknod(void)
{
8010618d:	55                   	push   %ebp
8010618e:	89 e5                	mov    %esp,%ebp
80106190:	83 ec 28             	sub    $0x28,%esp
  struct inode *ip;
  char *path;
  int len;
  int major, minor;
  
  begin_op();
80106193:	e8 d8 d3 ff ff       	call   80103570 <begin_op>
  if((len=argstr(0, &path)) < 0 ||
80106198:	83 ec 08             	sub    $0x8,%esp
8010619b:	8d 45 ec             	lea    -0x14(%ebp),%eax
8010619e:	50                   	push   %eax
8010619f:	6a 00                	push   $0x0
801061a1:	e8 e6 f4 ff ff       	call   8010568c <argstr>
801061a6:	83 c4 10             	add    $0x10,%esp
801061a9:	89 45 f4             	mov    %eax,-0xc(%ebp)
801061ac:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801061b0:	78 4f                	js     80106201 <sys_mknod+0x74>
     argint(1, &major) < 0 ||
801061b2:	83 ec 08             	sub    $0x8,%esp
801061b5:	8d 45 e8             	lea    -0x18(%ebp),%eax
801061b8:	50                   	push   %eax
801061b9:	6a 01                	push   $0x1
801061bb:	e8 47 f4 ff ff       	call   80105607 <argint>
801061c0:	83 c4 10             	add    $0x10,%esp
  if((len=argstr(0, &path)) < 0 ||
801061c3:	85 c0                	test   %eax,%eax
801061c5:	78 3a                	js     80106201 <sys_mknod+0x74>
     argint(2, &minor) < 0 ||
801061c7:	83 ec 08             	sub    $0x8,%esp
801061ca:	8d 45 e4             	lea    -0x1c(%ebp),%eax
801061cd:	50                   	push   %eax
801061ce:	6a 02                	push   $0x2
801061d0:	e8 32 f4 ff ff       	call   80105607 <argint>
801061d5:	83 c4 10             	add    $0x10,%esp
     argint(1, &major) < 0 ||
801061d8:	85 c0                	test   %eax,%eax
801061da:	78 25                	js     80106201 <sys_mknod+0x74>
     (ip = create(path, T_DEV, major, minor)) == 0){
801061dc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801061df:	0f bf c8             	movswl %ax,%ecx
801061e2:	8b 45 e8             	mov    -0x18(%ebp),%eax
801061e5:	0f bf d0             	movswl %ax,%edx
801061e8:	8b 45 ec             	mov    -0x14(%ebp),%eax
801061eb:	51                   	push   %ecx
801061ec:	52                   	push   %edx
801061ed:	6a 03                	push   $0x3
801061ef:	50                   	push   %eax
801061f0:	e8 c8 fb ff ff       	call   80105dbd <create>
801061f5:	83 c4 10             	add    $0x10,%esp
801061f8:	89 45 f0             	mov    %eax,-0x10(%ebp)
     argint(2, &minor) < 0 ||
801061fb:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801061ff:	75 0c                	jne    8010620d <sys_mknod+0x80>
    end_op();
80106201:	e8 f6 d3 ff ff       	call   801035fc <end_op>
    return -1;
80106206:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010620b:	eb 18                	jmp    80106225 <sys_mknod+0x98>
  }
  iunlockput(ip);
8010620d:	83 ec 0c             	sub    $0xc,%esp
80106210:	ff 75 f0             	push   -0x10(%ebp)
80106213:	e8 31 ba ff ff       	call   80101c49 <iunlockput>
80106218:	83 c4 10             	add    $0x10,%esp
  end_op();
8010621b:	e8 dc d3 ff ff       	call   801035fc <end_op>
  return 0;
80106220:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106225:	c9                   	leave
80106226:	c3                   	ret

80106227 <sys_chdir>:

int
sys_chdir(void)
{
80106227:	55                   	push   %ebp
80106228:	89 e5                	mov    %esp,%ebp
8010622a:	83 ec 18             	sub    $0x18,%esp
  char *path;
  struct inode *ip;

  begin_op();
8010622d:	e8 3e d3 ff ff       	call   80103570 <begin_op>
  if(argstr(0, &path) < 0 || (ip = namei(path)) == 0){
80106232:	83 ec 08             	sub    $0x8,%esp
80106235:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106238:	50                   	push   %eax
80106239:	6a 00                	push   $0x0
8010623b:	e8 4c f4 ff ff       	call   8010568c <argstr>
80106240:	83 c4 10             	add    $0x10,%esp
80106243:	85 c0                	test   %eax,%eax
80106245:	78 18                	js     8010625f <sys_chdir+0x38>
80106247:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010624a:	83 ec 0c             	sub    $0xc,%esp
8010624d:	50                   	push   %eax
8010624e:	e8 e7 c2 ff ff       	call   8010253a <namei>
80106253:	83 c4 10             	add    $0x10,%esp
80106256:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106259:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010625d:	75 0c                	jne    8010626b <sys_chdir+0x44>
    end_op();
8010625f:	e8 98 d3 ff ff       	call   801035fc <end_op>
    return -1;
80106264:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106269:	eb 6e                	jmp    801062d9 <sys_chdir+0xb2>
  }
  ilock(ip);
8010626b:	83 ec 0c             	sub    $0xc,%esp
8010626e:	ff 75 f4             	push   -0xc(%ebp)
80106271:	e8 13 b7 ff ff       	call   80101989 <ilock>
80106276:	83 c4 10             	add    $0x10,%esp
  if(ip->type != T_DIR){
80106279:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010627c:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80106280:	66 83 f8 01          	cmp    $0x1,%ax
80106284:	74 1a                	je     801062a0 <sys_chdir+0x79>
    iunlockput(ip);
80106286:	83 ec 0c             	sub    $0xc,%esp
80106289:	ff 75 f4             	push   -0xc(%ebp)
8010628c:	e8 b8 b9 ff ff       	call   80101c49 <iunlockput>
80106291:	83 c4 10             	add    $0x10,%esp
    end_op();
80106294:	e8 63 d3 ff ff       	call   801035fc <end_op>
    return -1;
80106299:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010629e:	eb 39                	jmp    801062d9 <sys_chdir+0xb2>
  }
  iunlock(ip);
801062a0:	83 ec 0c             	sub    $0xc,%esp
801062a3:	ff 75 f4             	push   -0xc(%ebp)
801062a6:	e8 3c b8 ff ff       	call   80101ae7 <iunlock>
801062ab:	83 c4 10             	add    $0x10,%esp
  iput(proc->cwd);
801062ae:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801062b4:	8b 40 68             	mov    0x68(%eax),%eax
801062b7:	83 ec 0c             	sub    $0xc,%esp
801062ba:	50                   	push   %eax
801062bb:	e8 99 b8 ff ff       	call   80101b59 <iput>
801062c0:	83 c4 10             	add    $0x10,%esp
  end_op();
801062c3:	e8 34 d3 ff ff       	call   801035fc <end_op>
  proc->cwd = ip;
801062c8:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801062ce:	8b 55 f4             	mov    -0xc(%ebp),%edx
801062d1:	89 50 68             	mov    %edx,0x68(%eax)
  return 0;
801062d4:	b8 00 00 00 00       	mov    $0x0,%eax
}
801062d9:	c9                   	leave
801062da:	c3                   	ret

801062db <sys_exec>:

int
sys_exec(void)
{
801062db:	55                   	push   %ebp
801062dc:	89 e5                	mov    %esp,%ebp
801062de:	81 ec 98 00 00 00    	sub    $0x98,%esp
  char *path, *argv[MAXARG];
  int i;
  uint uargv, uarg;

  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
801062e4:	83 ec 08             	sub    $0x8,%esp
801062e7:	8d 45 f0             	lea    -0x10(%ebp),%eax
801062ea:	50                   	push   %eax
801062eb:	6a 00                	push   $0x0
801062ed:	e8 9a f3 ff ff       	call   8010568c <argstr>
801062f2:	83 c4 10             	add    $0x10,%esp
801062f5:	85 c0                	test   %eax,%eax
801062f7:	78 18                	js     80106311 <sys_exec+0x36>
801062f9:	83 ec 08             	sub    $0x8,%esp
801062fc:	8d 85 6c ff ff ff    	lea    -0x94(%ebp),%eax
80106302:	50                   	push   %eax
80106303:	6a 01                	push   $0x1
80106305:	e8 fd f2 ff ff       	call   80105607 <argint>
8010630a:	83 c4 10             	add    $0x10,%esp
8010630d:	85 c0                	test   %eax,%eax
8010630f:	79 0a                	jns    8010631b <sys_exec+0x40>
    return -1;
80106311:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106316:	e9 c6 00 00 00       	jmp    801063e1 <sys_exec+0x106>
  }
  memset(argv, 0, sizeof(argv));
8010631b:	83 ec 04             	sub    $0x4,%esp
8010631e:	68 80 00 00 00       	push   $0x80
80106323:	6a 00                	push   $0x0
80106325:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
8010632b:	50                   	push   %eax
8010632c:	e8 b2 ef ff ff       	call   801052e3 <memset>
80106331:	83 c4 10             	add    $0x10,%esp
  for(i=0;; i++){
80106334:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    if(i >= NELEM(argv))
8010633b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010633e:	83 f8 1f             	cmp    $0x1f,%eax
80106341:	76 0a                	jbe    8010634d <sys_exec+0x72>
      return -1;
80106343:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106348:	e9 94 00 00 00       	jmp    801063e1 <sys_exec+0x106>
    if(fetchint(uargv+4*i, (int*)&uarg) < 0)
8010634d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106350:	c1 e0 02             	shl    $0x2,%eax
80106353:	89 c2                	mov    %eax,%edx
80106355:	8b 85 6c ff ff ff    	mov    -0x94(%ebp),%eax
8010635b:	01 c2                	add    %eax,%edx
8010635d:	83 ec 08             	sub    $0x8,%esp
80106360:	8d 85 68 ff ff ff    	lea    -0x98(%ebp),%eax
80106366:	50                   	push   %eax
80106367:	52                   	push   %edx
80106368:	e8 00 f2 ff ff       	call   8010556d <fetchint>
8010636d:	83 c4 10             	add    $0x10,%esp
80106370:	85 c0                	test   %eax,%eax
80106372:	79 07                	jns    8010637b <sys_exec+0xa0>
      return -1;
80106374:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106379:	eb 66                	jmp    801063e1 <sys_exec+0x106>
    if(uarg == 0){
8010637b:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
80106381:	85 c0                	test   %eax,%eax
80106383:	75 27                	jne    801063ac <sys_exec+0xd1>
      argv[i] = 0;
80106385:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106388:	c7 84 85 70 ff ff ff 	movl   $0x0,-0x90(%ebp,%eax,4)
8010638f:	00 00 00 00 
      break;
80106393:	90                   	nop
    }
    if(fetchstr(uarg, &argv[i]) < 0)
      return -1;
  }
  return exec(path, argv);
80106394:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106397:	83 ec 08             	sub    $0x8,%esp
8010639a:	8d 95 70 ff ff ff    	lea    -0x90(%ebp),%edx
801063a0:	52                   	push   %edx
801063a1:	50                   	push   %eax
801063a2:	e8 fb a7 ff ff       	call   80100ba2 <exec>
801063a7:	83 c4 10             	add    $0x10,%esp
801063aa:	eb 35                	jmp    801063e1 <sys_exec+0x106>
    if(fetchstr(uarg, &argv[i]) < 0)
801063ac:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
801063b2:	8b 55 f4             	mov    -0xc(%ebp),%edx
801063b5:	c1 e2 02             	shl    $0x2,%edx
801063b8:	01 c2                	add    %eax,%edx
801063ba:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
801063c0:	83 ec 08             	sub    $0x8,%esp
801063c3:	52                   	push   %edx
801063c4:	50                   	push   %eax
801063c5:	e8 dd f1 ff ff       	call   801055a7 <fetchstr>
801063ca:	83 c4 10             	add    $0x10,%esp
801063cd:	85 c0                	test   %eax,%eax
801063cf:	79 07                	jns    801063d8 <sys_exec+0xfd>
      return -1;
801063d1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801063d6:	eb 09                	jmp    801063e1 <sys_exec+0x106>
  for(i=0;; i++){
801063d8:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    if(i >= NELEM(argv))
801063dc:	e9 5a ff ff ff       	jmp    8010633b <sys_exec+0x60>
}
801063e1:	c9                   	leave
801063e2:	c3                   	ret

801063e3 <sys_pipe>:

int
sys_pipe(void)
{
801063e3:	55                   	push   %ebp
801063e4:	89 e5                	mov    %esp,%ebp
801063e6:	83 ec 28             	sub    $0x28,%esp
  int *fd;
  struct file *rf, *wf;
  int fd0, fd1;

  if(argptr(0, (void*)&fd, 2*sizeof(fd[0])) < 0)
801063e9:	83 ec 04             	sub    $0x4,%esp
801063ec:	6a 08                	push   $0x8
801063ee:	8d 45 ec             	lea    -0x14(%ebp),%eax
801063f1:	50                   	push   %eax
801063f2:	6a 00                	push   $0x0
801063f4:	e8 36 f2 ff ff       	call   8010562f <argptr>
801063f9:	83 c4 10             	add    $0x10,%esp
801063fc:	85 c0                	test   %eax,%eax
801063fe:	79 0a                	jns    8010640a <sys_pipe+0x27>
    return -1;
80106400:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106405:	e9 af 00 00 00       	jmp    801064b9 <sys_pipe+0xd6>
  if(pipealloc(&rf, &wf) < 0)
8010640a:	83 ec 08             	sub    $0x8,%esp
8010640d:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80106410:	50                   	push   %eax
80106411:	8d 45 e8             	lea    -0x18(%ebp),%eax
80106414:	50                   	push   %eax
80106415:	e8 64 dc ff ff       	call   8010407e <pipealloc>
8010641a:	83 c4 10             	add    $0x10,%esp
8010641d:	85 c0                	test   %eax,%eax
8010641f:	79 0a                	jns    8010642b <sys_pipe+0x48>
    return -1;
80106421:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106426:	e9 8e 00 00 00       	jmp    801064b9 <sys_pipe+0xd6>
  fd0 = -1;
8010642b:	c7 45 f4 ff ff ff ff 	movl   $0xffffffff,-0xc(%ebp)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
80106432:	8b 45 e8             	mov    -0x18(%ebp),%eax
80106435:	83 ec 0c             	sub    $0xc,%esp
80106438:	50                   	push   %eax
80106439:	e8 79 f3 ff ff       	call   801057b7 <fdalloc>
8010643e:	83 c4 10             	add    $0x10,%esp
80106441:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106444:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106448:	78 18                	js     80106462 <sys_pipe+0x7f>
8010644a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010644d:	83 ec 0c             	sub    $0xc,%esp
80106450:	50                   	push   %eax
80106451:	e8 61 f3 ff ff       	call   801057b7 <fdalloc>
80106456:	83 c4 10             	add    $0x10,%esp
80106459:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010645c:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80106460:	79 3f                	jns    801064a1 <sys_pipe+0xbe>
    if(fd0 >= 0)
80106462:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106466:	78 14                	js     8010647c <sys_pipe+0x99>
      proc->ofile[fd0] = 0;
80106468:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010646e:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106471:	83 c2 08             	add    $0x8,%edx
80106474:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
8010647b:	00 
    fileclose(rf);
8010647c:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010647f:	83 ec 0c             	sub    $0xc,%esp
80106482:	50                   	push   %eax
80106483:	e8 fa ab ff ff       	call   80101082 <fileclose>
80106488:	83 c4 10             	add    $0x10,%esp
    fileclose(wf);
8010648b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010648e:	83 ec 0c             	sub    $0xc,%esp
80106491:	50                   	push   %eax
80106492:	e8 eb ab ff ff       	call   80101082 <fileclose>
80106497:	83 c4 10             	add    $0x10,%esp
    return -1;
8010649a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010649f:	eb 18                	jmp    801064b9 <sys_pipe+0xd6>
  }
  fd[0] = fd0;
801064a1:	8b 45 ec             	mov    -0x14(%ebp),%eax
801064a4:	8b 55 f4             	mov    -0xc(%ebp),%edx
801064a7:	89 10                	mov    %edx,(%eax)
  fd[1] = fd1;
801064a9:	8b 45 ec             	mov    -0x14(%ebp),%eax
801064ac:	8d 50 04             	lea    0x4(%eax),%edx
801064af:	8b 45 f0             	mov    -0x10(%ebp),%eax
801064b2:	89 02                	mov    %eax,(%edx)
  return 0;
801064b4:	b8 00 00 00 00       	mov    $0x0,%eax
}
801064b9:	c9                   	leave
801064ba:	c3                   	ret

801064bb <sys_fork>:

extern int page_allocator_type; 
extern int free_frame_cnt; // CS3320 for project3
int
sys_fork(void)
{
801064bb:	55                   	push   %ebp
801064bc:	89 e5                	mov    %esp,%ebp
801064be:	83 ec 08             	sub    $0x8,%esp
  return fork();
801064c1:	e8 cf e2 ff ff       	call   80104795 <fork>
}
801064c6:	c9                   	leave
801064c7:	c3                   	ret

801064c8 <sys_exit>:

int
sys_exit(void)
{
801064c8:	55                   	push   %ebp
801064c9:	89 e5                	mov    %esp,%ebp
801064cb:	83 ec 08             	sub    $0x8,%esp
  exit();
801064ce:	e8 4f e4 ff ff       	call   80104922 <exit>
  return 0;  // not reached
801064d3:	b8 00 00 00 00       	mov    $0x0,%eax
}
801064d8:	c9                   	leave
801064d9:	c3                   	ret

801064da <sys_wait>:

int
sys_wait(void)
{
801064da:	55                   	push   %ebp
801064db:	89 e5                	mov    %esp,%ebp
801064dd:	83 ec 08             	sub    $0x8,%esp
  return wait();
801064e0:	e8 75 e5 ff ff       	call   80104a5a <wait>
}
801064e5:	c9                   	leave
801064e6:	c3                   	ret

801064e7 <sys_kill>:

int
sys_kill(void)
{
801064e7:	55                   	push   %ebp
801064e8:	89 e5                	mov    %esp,%ebp
801064ea:	83 ec 18             	sub    $0x18,%esp
  int pid;

  if(argint(0, &pid) < 0)
801064ed:	83 ec 08             	sub    $0x8,%esp
801064f0:	8d 45 f4             	lea    -0xc(%ebp),%eax
801064f3:	50                   	push   %eax
801064f4:	6a 00                	push   $0x0
801064f6:	e8 0c f1 ff ff       	call   80105607 <argint>
801064fb:	83 c4 10             	add    $0x10,%esp
801064fe:	85 c0                	test   %eax,%eax
80106500:	79 07                	jns    80106509 <sys_kill+0x22>
    return -1;
80106502:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106507:	eb 0f                	jmp    80106518 <sys_kill+0x31>
  return kill(pid);
80106509:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010650c:	83 ec 0c             	sub    $0xc,%esp
8010650f:	50                   	push   %eax
80106510:	e8 92 e9 ff ff       	call   80104ea7 <kill>
80106515:	83 c4 10             	add    $0x10,%esp
}
80106518:	c9                   	leave
80106519:	c3                   	ret

8010651a <sys_getpid>:

int
sys_getpid(void)
{
8010651a:	55                   	push   %ebp
8010651b:	89 e5                	mov    %esp,%ebp
  return proc->pid;
8010651d:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106523:	8b 40 10             	mov    0x10(%eax),%eax
}
80106526:	5d                   	pop    %ebp
80106527:	c3                   	ret

80106528 <sys_sbrk>:

int
sys_sbrk(void)
{
80106528:	55                   	push   %ebp
80106529:	89 e5                	mov    %esp,%ebp
8010652b:	83 ec 18             	sub    $0x18,%esp
  int addr;
  int n;

  if(argint(0, &n) < 0)
8010652e:	83 ec 08             	sub    $0x8,%esp
80106531:	8d 45 ec             	lea    -0x14(%ebp),%eax
80106534:	50                   	push   %eax
80106535:	6a 00                	push   $0x0
80106537:	e8 cb f0 ff ff       	call   80105607 <argint>
8010653c:	83 c4 10             	add    $0x10,%esp
8010653f:	85 c0                	test   %eax,%eax
80106541:	79 0a                	jns    8010654d <sys_sbrk+0x25>
  {
    return -1;
80106543:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106548:	e9 d8 00 00 00       	jmp    80106625 <sys_sbrk+0xfd>
  } 

  addr = proc->sz;
8010654d:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106553:	8b 00                	mov    (%eax),%eax
80106555:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(n < 0) // if we are deallocating pages
80106558:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010655b:	85 c0                	test   %eax,%eax
8010655d:	79 25                	jns    80106584 <sys_sbrk+0x5c>
  {
    // try to deallocate pages and return -1 if failed
    if(growproc(n) < 0)
8010655f:	8b 45 ec             	mov    -0x14(%ebp),%eax
80106562:	83 ec 0c             	sub    $0xc,%esp
80106565:	50                   	push   %eax
80106566:	e8 67 e1 ff ff       	call   801046d2 <growproc>
8010656b:	83 c4 10             	add    $0x10,%esp
8010656e:	85 c0                	test   %eax,%eax
80106570:	79 0a                	jns    8010657c <sys_sbrk+0x54>
    {
      return -1;
80106572:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106577:	e9 a9 00 00 00       	jmp    80106625 <sys_sbrk+0xfd>
    }
    else 
    {
      return addr;
8010657c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010657f:	e9 a1 00 00 00       	jmp    80106625 <sys_sbrk+0xfd>
    }
  }
  else if (n > 0) // if we are allocating pages 
80106584:	8b 45 ec             	mov    -0x14(%ebp),%eax
80106587:	85 c0                	test   %eax,%eax
80106589:	0f 8e 8e 00 00 00    	jle    8010661d <sys_sbrk+0xf5>
  {
    if(page_allocator_type == 0) // default page allocator
8010658f:	a1 60 19 11 80       	mov    0x80111960,%eax
80106594:	85 c0                	test   %eax,%eax
80106596:	75 1f                	jne    801065b7 <sys_sbrk+0x8f>
    {
      // do the normal allocation 
      if(growproc(n) < 0)
80106598:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010659b:	83 ec 0c             	sub    $0xc,%esp
8010659e:	50                   	push   %eax
8010659f:	e8 2e e1 ff ff       	call   801046d2 <growproc>
801065a4:	83 c4 10             	add    $0x10,%esp
801065a7:	85 c0                	test   %eax,%eax
801065a9:	79 07                	jns    801065b2 <sys_sbrk+0x8a>
      {
        return -1;
801065ab:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801065b0:	eb 73                	jmp    80106625 <sys_sbrk+0xfd>
      }
      else 
      {
        return addr;
801065b2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801065b5:	eb 6e                	jmp    80106625 <sys_sbrk+0xfd>
      }
    }
    else if (page_allocator_type == 1) // lazy page allocator
801065b7:	a1 60 19 11 80       	mov    0x80111960,%eax
801065bc:	83 f8 01             	cmp    $0x1,%eax
801065bf:	75 55                	jne    80106616 <sys_sbrk+0xee>
    {
      uint old = proc->sz;
801065c1:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801065c7:	8b 00                	mov    (%eax),%eax
801065c9:	89 45 f0             	mov    %eax,-0x10(%ebp)
      proc->sz += n; // Increase the virtual size without allocating pages
801065cc:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801065d2:	8b 10                	mov    (%eax),%edx
801065d4:	8b 45 ec             	mov    -0x14(%ebp),%eax
801065d7:	89 c1                	mov    %eax,%ecx
801065d9:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801065df:	01 ca                	add    %ecx,%edx
801065e1:	89 10                	mov    %edx,(%eax)
      if (proc->sz >= KERNBASE) // check if we expanded into kernel space
801065e3:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801065e9:	8b 00                	mov    (%eax),%eax
801065eb:	85 c0                	test   %eax,%eax
801065ed:	79 22                	jns    80106611 <sys_sbrk+0xe9>
      {
        proc->sz = old; // If so, revert size change and return -1
801065ef:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801065f5:	8b 55 f0             	mov    -0x10(%ebp),%edx
801065f8:	89 10                	mov    %edx,(%eax)
        cprintf("Allocating pages failed!\n");
801065fa:	83 ec 0c             	sub    $0xc,%esp
801065fd:	68 f0 8c 10 80       	push   $0x80108cf0
80106602:	e8 bd 9d ff ff       	call   801003c4 <cprintf>
80106607:	83 c4 10             	add    $0x10,%esp
        return -1;
8010660a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010660f:	eb 14                	jmp    80106625 <sys_sbrk+0xfd>
      }
      return addr; 
80106611:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106614:	eb 0f                	jmp    80106625 <sys_sbrk+0xfd>
    }
    else 
    {
      return -1; // invalid page allocator type Should never happen but the compiler was yelling
80106616:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010661b:	eb 08                	jmp    80106625 <sys_sbrk+0xfd>
    }
  }
  else return proc->sz; // n == 0, do nothing
8010661d:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106623:	8b 00                	mov    (%eax),%eax
}
80106625:	c9                   	leave
80106626:	c3                   	ret

80106627 <sys_sleep>:

int
sys_sleep(void)
{
80106627:	55                   	push   %ebp
80106628:	89 e5                	mov    %esp,%ebp
8010662a:	83 ec 18             	sub    $0x18,%esp
  int n;
  uint ticks0;
  
  if(argint(0, &n) < 0)
8010662d:	83 ec 08             	sub    $0x8,%esp
80106630:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106633:	50                   	push   %eax
80106634:	6a 00                	push   $0x0
80106636:	e8 cc ef ff ff       	call   80105607 <argint>
8010663b:	83 c4 10             	add    $0x10,%esp
8010663e:	85 c0                	test   %eax,%eax
80106640:	79 07                	jns    80106649 <sys_sleep+0x22>
    return -1;
80106642:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106647:	eb 77                	jmp    801066c0 <sys_sleep+0x99>
  acquire(&tickslock);
80106649:	83 ec 0c             	sub    $0xc,%esp
8010664c:	68 c0 40 11 80       	push   $0x801140c0
80106651:	e8 29 ea ff ff       	call   8010507f <acquire>
80106656:	83 c4 10             	add    $0x10,%esp
  ticks0 = ticks;
80106659:	a1 f4 40 11 80       	mov    0x801140f4,%eax
8010665e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(ticks - ticks0 < n){
80106661:	eb 39                	jmp    8010669c <sys_sleep+0x75>
    if(proc->killed){
80106663:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106669:	8b 40 24             	mov    0x24(%eax),%eax
8010666c:	85 c0                	test   %eax,%eax
8010666e:	74 17                	je     80106687 <sys_sleep+0x60>
      release(&tickslock);
80106670:	83 ec 0c             	sub    $0xc,%esp
80106673:	68 c0 40 11 80       	push   $0x801140c0
80106678:	e8 69 ea ff ff       	call   801050e6 <release>
8010667d:	83 c4 10             	add    $0x10,%esp
      return -1;
80106680:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106685:	eb 39                	jmp    801066c0 <sys_sleep+0x99>
    }
    sleep(&ticks, &tickslock);
80106687:	83 ec 08             	sub    $0x8,%esp
8010668a:	68 c0 40 11 80       	push   $0x801140c0
8010668f:	68 f4 40 11 80       	push   $0x801140f4
80106694:	e8 eb e6 ff ff       	call   80104d84 <sleep>
80106699:	83 c4 10             	add    $0x10,%esp
  while(ticks - ticks0 < n){
8010669c:	a1 f4 40 11 80       	mov    0x801140f4,%eax
801066a1:	2b 45 f4             	sub    -0xc(%ebp),%eax
801066a4:	8b 55 f0             	mov    -0x10(%ebp),%edx
801066a7:	39 d0                	cmp    %edx,%eax
801066a9:	72 b8                	jb     80106663 <sys_sleep+0x3c>
  }
  release(&tickslock);
801066ab:	83 ec 0c             	sub    $0xc,%esp
801066ae:	68 c0 40 11 80       	push   $0x801140c0
801066b3:	e8 2e ea ff ff       	call   801050e6 <release>
801066b8:	83 c4 10             	add    $0x10,%esp
  return 0;
801066bb:	b8 00 00 00 00       	mov    $0x0,%eax
}
801066c0:	c9                   	leave
801066c1:	c3                   	ret

801066c2 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
int
sys_uptime(void)
{
801066c2:	55                   	push   %ebp
801066c3:	89 e5                	mov    %esp,%ebp
801066c5:	83 ec 18             	sub    $0x18,%esp
  uint xticks;
  
  acquire(&tickslock);
801066c8:	83 ec 0c             	sub    $0xc,%esp
801066cb:	68 c0 40 11 80       	push   $0x801140c0
801066d0:	e8 aa e9 ff ff       	call   8010507f <acquire>
801066d5:	83 c4 10             	add    $0x10,%esp
  xticks = ticks;
801066d8:	a1 f4 40 11 80       	mov    0x801140f4,%eax
801066dd:	89 45 f4             	mov    %eax,-0xc(%ebp)
  release(&tickslock);
801066e0:	83 ec 0c             	sub    $0xc,%esp
801066e3:	68 c0 40 11 80       	push   $0x801140c0
801066e8:	e8 f9 e9 ff ff       	call   801050e6 <release>
801066ed:	83 c4 10             	add    $0x10,%esp
  return xticks;
801066f0:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801066f3:	c9                   	leave
801066f4:	c3                   	ret

801066f5 <sys_print_free_frame_cnt>:

// CS 3320 print out free frames
int sys_print_free_frame_cnt(void)
{
801066f5:	55                   	push   %ebp
801066f6:	89 e5                	mov    %esp,%ebp
801066f8:	83 ec 08             	sub    $0x8,%esp
    cprintf("free-frames %d\n", free_frame_cnt);
801066fb:	a1 00 12 11 80       	mov    0x80111200,%eax
80106700:	83 ec 08             	sub    $0x8,%esp
80106703:	50                   	push   %eax
80106704:	68 0a 8d 10 80       	push   $0x80108d0a
80106709:	e8 b6 9c ff ff       	call   801003c4 <cprintf>
8010670e:	83 c4 10             	add    $0x10,%esp
    return 0;
80106711:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106716:	c9                   	leave
80106717:	c3                   	ret

80106718 <sys_set_page_allocator>:

// CS 3320 set page allocator
extern int page_allocator_type;
int sys_set_page_allocator(void)
{
80106718:	55                   	push   %ebp
80106719:	89 e5                	mov    %esp,%ebp
8010671b:	83 ec 08             	sub    $0x8,%esp
    if(argint(0,&page_allocator_type) < 0){
8010671e:	83 ec 08             	sub    $0x8,%esp
80106721:	68 60 19 11 80       	push   $0x80111960
80106726:	6a 00                	push   $0x0
80106728:	e8 da ee ff ff       	call   80105607 <argint>
8010672d:	83 c4 10             	add    $0x10,%esp
80106730:	85 c0                	test   %eax,%eax
80106732:	79 07                	jns    8010673b <sys_set_page_allocator+0x23>
        return -1;
80106734:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106739:	eb 05                	jmp    80106740 <sys_set_page_allocator+0x28>
    }
    // please remove the following 
    // when you start implementing your page allocator
    return 0;
8010673b:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106740:	c9                   	leave
80106741:	c3                   	ret

80106742 <sys_shmget>:

// CS 3320 shared memory
int sys_shmget(void)
{
80106742:	55                   	push   %ebp
80106743:	89 e5                	mov    %esp,%ebp
80106745:	83 ec 18             	sub    $0x18,%esp
    int shm_id;
    if(argint(0, &shm_id) < 0){
80106748:	83 ec 08             	sub    $0x8,%esp
8010674b:	8d 45 f4             	lea    -0xc(%ebp),%eax
8010674e:	50                   	push   %eax
8010674f:	6a 00                	push   $0x0
80106751:	e8 b1 ee ff ff       	call   80105607 <argint>
80106756:	83 c4 10             	add    $0x10,%esp
80106759:	85 c0                	test   %eax,%eax
8010675b:	79 07                	jns    80106764 <sys_shmget+0x22>
        return -1;
8010675d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106762:	eb 15                	jmp    80106779 <sys_shmget+0x37>
    }
    cprintf("Your shared memory mechanism has not been implemented!\n");    
80106764:	83 ec 0c             	sub    $0xc,%esp
80106767:	68 1c 8d 10 80       	push   $0x80108d1c
8010676c:	e8 53 9c ff ff       	call   801003c4 <cprintf>
80106771:	83 c4 10             	add    $0x10,%esp
    return 0;
80106774:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106779:	c9                   	leave
8010677a:	c3                   	ret

8010677b <sys_shmdel>:

// delete a shared page
int sys_shmdel(void)
{
8010677b:	55                   	push   %ebp
8010677c:	89 e5                	mov    %esp,%ebp
8010677e:	83 ec 18             	sub    $0x18,%esp
    int shm_id;
    if(argint(0, &shm_id) < 0){
80106781:	83 ec 08             	sub    $0x8,%esp
80106784:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106787:	50                   	push   %eax
80106788:	6a 00                	push   $0x0
8010678a:	e8 78 ee ff ff       	call   80105607 <argint>
8010678f:	83 c4 10             	add    $0x10,%esp
80106792:	85 c0                	test   %eax,%eax
80106794:	79 07                	jns    8010679d <sys_shmdel+0x22>
        return -1;
80106796:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010679b:	eb 15                	jmp    801067b2 <sys_shmdel+0x37>
    }
    cprintf("Your shared memory mechanims has not been implemented!\n");
8010679d:	83 ec 0c             	sub    $0xc,%esp
801067a0:	68 54 8d 10 80       	push   $0x80108d54
801067a5:	e8 1a 9c ff ff       	call   801003c4 <cprintf>
801067aa:	83 c4 10             	add    $0x10,%esp
    return 0;
801067ad:	b8 00 00 00 00       	mov    $0x0,%eax
}
801067b2:	c9                   	leave
801067b3:	c3                   	ret

801067b4 <outb>:
{
801067b4:	55                   	push   %ebp
801067b5:	89 e5                	mov    %esp,%ebp
801067b7:	83 ec 08             	sub    $0x8,%esp
801067ba:	8b 55 08             	mov    0x8(%ebp),%edx
801067bd:	8b 45 0c             	mov    0xc(%ebp),%eax
801067c0:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
801067c4:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
801067c7:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
801067cb:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
801067cf:	ee                   	out    %al,(%dx)
}
801067d0:	90                   	nop
801067d1:	c9                   	leave
801067d2:	c3                   	ret

801067d3 <timerinit>:
#define TIMER_RATEGEN   0x04    // mode 2, rate generator
#define TIMER_16BIT     0x30    // r/w counter 16 bits, LSB first

void
timerinit(void)
{
801067d3:	55                   	push   %ebp
801067d4:	89 e5                	mov    %esp,%ebp
801067d6:	83 ec 08             	sub    $0x8,%esp
  // Interrupt 100 times/sec.
  outb(TIMER_MODE, TIMER_SEL0 | TIMER_RATEGEN | TIMER_16BIT);
801067d9:	6a 34                	push   $0x34
801067db:	6a 43                	push   $0x43
801067dd:	e8 d2 ff ff ff       	call   801067b4 <outb>
801067e2:	83 c4 08             	add    $0x8,%esp
  outb(IO_TIMER1, TIMER_DIV(100) % 256);
801067e5:	68 9c 00 00 00       	push   $0x9c
801067ea:	6a 40                	push   $0x40
801067ec:	e8 c3 ff ff ff       	call   801067b4 <outb>
801067f1:	83 c4 08             	add    $0x8,%esp
  outb(IO_TIMER1, TIMER_DIV(100) / 256);
801067f4:	6a 2e                	push   $0x2e
801067f6:	6a 40                	push   $0x40
801067f8:	e8 b7 ff ff ff       	call   801067b4 <outb>
801067fd:	83 c4 08             	add    $0x8,%esp
  picenable(IRQ_TIMER);
80106800:	83 ec 0c             	sub    $0xc,%esp
80106803:	6a 00                	push   $0x0
80106805:	e8 5e d7 ff ff       	call   80103f68 <picenable>
8010680a:	83 c4 10             	add    $0x10,%esp
}
8010680d:	90                   	nop
8010680e:	c9                   	leave
8010680f:	c3                   	ret

80106810 <alltraps>:

  # vectors.S sends all traps here.
.globl alltraps
alltraps:
  # Build trap frame.
  pushl %ds
80106810:	1e                   	push   %ds
  pushl %es
80106811:	06                   	push   %es
  pushl %fs
80106812:	0f a0                	push   %fs
  pushl %gs
80106814:	0f a8                	push   %gs
  pushal
80106816:	60                   	pusha
  
  # Set up data and per-cpu segments.
  movw $(SEG_KDATA<<3), %ax
80106817:	66 b8 10 00          	mov    $0x10,%ax
  movw %ax, %ds
8010681b:	8e d8                	mov    %eax,%ds
  movw %ax, %es
8010681d:	8e c0                	mov    %eax,%es
  movw $(SEG_KCPU<<3), %ax
8010681f:	66 b8 18 00          	mov    $0x18,%ax
  movw %ax, %fs
80106823:	8e e0                	mov    %eax,%fs
  movw %ax, %gs
80106825:	8e e8                	mov    %eax,%gs

  # Call trap(tf), where tf=%esp
  pushl %esp
80106827:	54                   	push   %esp
  call trap
80106828:	e8 e4 01 00 00       	call   80106a11 <trap>
  addl $4, %esp
8010682d:	83 c4 04             	add    $0x4,%esp

80106830 <trapret>:

  # Return falls through to trapret...
.globl trapret
trapret:
  popal
80106830:	61                   	popa
  popl %gs
80106831:	0f a9                	pop    %gs
  popl %fs
80106833:	0f a1                	pop    %fs
  popl %es
80106835:	07                   	pop    %es
  popl %ds
80106836:	1f                   	pop    %ds
  addl $0x8, %esp  # trapno and errcode
80106837:	83 c4 08             	add    $0x8,%esp
  iret
8010683a:	cf                   	iret

8010683b <v2p>:
static inline uint v2p(void *a) { return ((uint) (a))  - KERNBASE; }
8010683b:	55                   	push   %ebp
8010683c:	89 e5                	mov    %esp,%ebp
8010683e:	8b 45 08             	mov    0x8(%ebp),%eax
80106841:	05 00 00 00 80       	add    $0x80000000,%eax
80106846:	5d                   	pop    %ebp
80106847:	c3                   	ret

80106848 <lidt>:
{
80106848:	55                   	push   %ebp
80106849:	89 e5                	mov    %esp,%ebp
8010684b:	83 ec 10             	sub    $0x10,%esp
  pd[0] = size-1;
8010684e:	8b 45 0c             	mov    0xc(%ebp),%eax
80106851:	83 e8 01             	sub    $0x1,%eax
80106854:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
80106858:	8b 45 08             	mov    0x8(%ebp),%eax
8010685b:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
8010685f:	8b 45 08             	mov    0x8(%ebp),%eax
80106862:	c1 e8 10             	shr    $0x10,%eax
80106865:	66 89 45 fe          	mov    %ax,-0x2(%ebp)
  asm volatile("lidt (%0)" : : "r" (pd));
80106869:	8d 45 fa             	lea    -0x6(%ebp),%eax
8010686c:	0f 01 18             	lidtl  (%eax)
}
8010686f:	90                   	nop
80106870:	c9                   	leave
80106871:	c3                   	ret

80106872 <rcr2>:
{
80106872:	55                   	push   %ebp
80106873:	89 e5                	mov    %esp,%ebp
80106875:	83 ec 10             	sub    $0x10,%esp
  asm volatile("movl %%cr2,%0" : "=r" (val));
80106878:	0f 20 d0             	mov    %cr2,%eax
8010687b:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return val;
8010687e:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80106881:	c9                   	leave
80106882:	c3                   	ret

80106883 <tvinit>:
int mappages(pde_t *pgdir, void *va, uint size, uint pa, int perm);
extern int page_allocator_type;

void
tvinit(void)
{
80106883:	55                   	push   %ebp
80106884:	89 e5                	mov    %esp,%ebp
80106886:	83 ec 18             	sub    $0x18,%esp
  int i;

  for(i = 0; i < 256; i++)
80106889:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80106890:	e9 c3 00 00 00       	jmp    80106958 <tvinit+0xd5>
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
80106895:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106898:	8b 04 85 ac b0 10 80 	mov    -0x7fef4f54(,%eax,4),%eax
8010689f:	89 c2                	mov    %eax,%edx
801068a1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801068a4:	66 89 14 c5 c0 38 11 	mov    %dx,-0x7feec740(,%eax,8)
801068ab:	80 
801068ac:	8b 45 f4             	mov    -0xc(%ebp),%eax
801068af:	66 c7 04 c5 c2 38 11 	movw   $0x8,-0x7feec73e(,%eax,8)
801068b6:	80 08 00 
801068b9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801068bc:	0f b6 14 c5 c4 38 11 	movzbl -0x7feec73c(,%eax,8),%edx
801068c3:	80 
801068c4:	83 e2 e0             	and    $0xffffffe0,%edx
801068c7:	88 14 c5 c4 38 11 80 	mov    %dl,-0x7feec73c(,%eax,8)
801068ce:	8b 45 f4             	mov    -0xc(%ebp),%eax
801068d1:	0f b6 14 c5 c4 38 11 	movzbl -0x7feec73c(,%eax,8),%edx
801068d8:	80 
801068d9:	83 e2 1f             	and    $0x1f,%edx
801068dc:	88 14 c5 c4 38 11 80 	mov    %dl,-0x7feec73c(,%eax,8)
801068e3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801068e6:	0f b6 14 c5 c5 38 11 	movzbl -0x7feec73b(,%eax,8),%edx
801068ed:	80 
801068ee:	83 e2 f0             	and    $0xfffffff0,%edx
801068f1:	83 ca 0e             	or     $0xe,%edx
801068f4:	88 14 c5 c5 38 11 80 	mov    %dl,-0x7feec73b(,%eax,8)
801068fb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801068fe:	0f b6 14 c5 c5 38 11 	movzbl -0x7feec73b(,%eax,8),%edx
80106905:	80 
80106906:	83 e2 ef             	and    $0xffffffef,%edx
80106909:	88 14 c5 c5 38 11 80 	mov    %dl,-0x7feec73b(,%eax,8)
80106910:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106913:	0f b6 14 c5 c5 38 11 	movzbl -0x7feec73b(,%eax,8),%edx
8010691a:	80 
8010691b:	83 e2 9f             	and    $0xffffff9f,%edx
8010691e:	88 14 c5 c5 38 11 80 	mov    %dl,-0x7feec73b(,%eax,8)
80106925:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106928:	0f b6 14 c5 c5 38 11 	movzbl -0x7feec73b(,%eax,8),%edx
8010692f:	80 
80106930:	83 ca 80             	or     $0xffffff80,%edx
80106933:	88 14 c5 c5 38 11 80 	mov    %dl,-0x7feec73b(,%eax,8)
8010693a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010693d:	8b 04 85 ac b0 10 80 	mov    -0x7fef4f54(,%eax,4),%eax
80106944:	c1 e8 10             	shr    $0x10,%eax
80106947:	89 c2                	mov    %eax,%edx
80106949:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010694c:	66 89 14 c5 c6 38 11 	mov    %dx,-0x7feec73a(,%eax,8)
80106953:	80 
  for(i = 0; i < 256; i++)
80106954:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80106958:	81 7d f4 ff 00 00 00 	cmpl   $0xff,-0xc(%ebp)
8010695f:	0f 8e 30 ff ff ff    	jle    80106895 <tvinit+0x12>
  SETGATE(idt[T_SYSCALL], 1, SEG_KCODE<<3, vectors[T_SYSCALL], DPL_USER);
80106965:	a1 ac b1 10 80       	mov    0x8010b1ac,%eax
8010696a:	66 a3 c0 3a 11 80    	mov    %ax,0x80113ac0
80106970:	66 c7 05 c2 3a 11 80 	movw   $0x8,0x80113ac2
80106977:	08 00 
80106979:	0f b6 05 c4 3a 11 80 	movzbl 0x80113ac4,%eax
80106980:	83 e0 e0             	and    $0xffffffe0,%eax
80106983:	a2 c4 3a 11 80       	mov    %al,0x80113ac4
80106988:	0f b6 05 c4 3a 11 80 	movzbl 0x80113ac4,%eax
8010698f:	83 e0 1f             	and    $0x1f,%eax
80106992:	a2 c4 3a 11 80       	mov    %al,0x80113ac4
80106997:	0f b6 05 c5 3a 11 80 	movzbl 0x80113ac5,%eax
8010699e:	83 c8 0f             	or     $0xf,%eax
801069a1:	a2 c5 3a 11 80       	mov    %al,0x80113ac5
801069a6:	0f b6 05 c5 3a 11 80 	movzbl 0x80113ac5,%eax
801069ad:	83 e0 ef             	and    $0xffffffef,%eax
801069b0:	a2 c5 3a 11 80       	mov    %al,0x80113ac5
801069b5:	0f b6 05 c5 3a 11 80 	movzbl 0x80113ac5,%eax
801069bc:	83 c8 60             	or     $0x60,%eax
801069bf:	a2 c5 3a 11 80       	mov    %al,0x80113ac5
801069c4:	0f b6 05 c5 3a 11 80 	movzbl 0x80113ac5,%eax
801069cb:	83 c8 80             	or     $0xffffff80,%eax
801069ce:	a2 c5 3a 11 80       	mov    %al,0x80113ac5
801069d3:	a1 ac b1 10 80       	mov    0x8010b1ac,%eax
801069d8:	c1 e8 10             	shr    $0x10,%eax
801069db:	66 a3 c6 3a 11 80    	mov    %ax,0x80113ac6
  
  initlock(&tickslock, "time");
801069e1:	83 ec 08             	sub    $0x8,%esp
801069e4:	68 8c 8d 10 80       	push   $0x80108d8c
801069e9:	68 c0 40 11 80       	push   $0x801140c0
801069ee:	e8 6a e6 ff ff       	call   8010505d <initlock>
801069f3:	83 c4 10             	add    $0x10,%esp
}
801069f6:	90                   	nop
801069f7:	c9                   	leave
801069f8:	c3                   	ret

801069f9 <idtinit>:

void
idtinit(void)
{
801069f9:	55                   	push   %ebp
801069fa:	89 e5                	mov    %esp,%ebp
  lidt(idt, sizeof(idt));
801069fc:	68 00 08 00 00       	push   $0x800
80106a01:	68 c0 38 11 80       	push   $0x801138c0
80106a06:	e8 3d fe ff ff       	call   80106848 <lidt>
80106a0b:	83 c4 08             	add    $0x8,%esp
}
80106a0e:	90                   	nop
80106a0f:	c9                   	leave
80106a10:	c3                   	ret

80106a11 <trap>:

//PAGEBREAK: 41
void
trap(struct trapframe *tf)
{
80106a11:	55                   	push   %ebp
80106a12:	89 e5                	mov    %esp,%ebp
80106a14:	57                   	push   %edi
80106a15:	56                   	push   %esi
80106a16:	53                   	push   %ebx
80106a17:	83 ec 2c             	sub    $0x2c,%esp
  if(tf->trapno == T_SYSCALL)
80106a1a:	8b 45 08             	mov    0x8(%ebp),%eax
80106a1d:	8b 40 30             	mov    0x30(%eax),%eax
80106a20:	83 f8 40             	cmp    $0x40,%eax
80106a23:	75 3e                	jne    80106a63 <trap+0x52>
  {
    if(proc->killed)
80106a25:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106a2b:	8b 40 24             	mov    0x24(%eax),%eax
80106a2e:	85 c0                	test   %eax,%eax
80106a30:	74 05                	je     80106a37 <trap+0x26>
      exit();
80106a32:	e8 eb de ff ff       	call   80104922 <exit>
    proc->tf = tf;
80106a37:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106a3d:	8b 55 08             	mov    0x8(%ebp),%edx
80106a40:	89 50 18             	mov    %edx,0x18(%eax)
    syscall();
80106a43:	e8 75 ec ff ff       	call   801056bd <syscall>
    if(proc->killed)
80106a48:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106a4e:	8b 40 24             	mov    0x24(%eax),%eax
80106a51:	85 c0                	test   %eax,%eax
80106a53:	0f 84 f9 02 00 00    	je     80106d52 <trap+0x341>
      exit();
80106a59:	e8 c4 de ff ff       	call   80104922 <exit>
    return;
80106a5e:	e9 ef 02 00 00       	jmp    80106d52 <trap+0x341>
  }
 // CS 3320 project 2
 // You might need to change the folloiwng default page fault handling
 // for your project 2
 if(tf->trapno == T_PGFLT)
80106a63:	8b 45 08             	mov    0x8(%ebp),%eax
80106a66:	8b 40 30             	mov    0x30(%eax),%eax
80106a69:	83 f8 0e             	cmp    $0xe,%eax
80106a6c:	0f 85 ce 00 00 00    	jne    80106b40 <trap+0x12f>
 {                 // CS 3320 project 2

    uint faulting_va;                       // CS 3320 project 2
    faulting_va = rcr2();                   // CS 3320 project 2
80106a72:	e8 fb fd ff ff       	call   80106872 <rcr2>
80106a77:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(page_allocator_type == 0)
80106a7a:	a1 60 19 11 80       	mov    0x80111960,%eax
80106a7f:	85 c0                	test   %eax,%eax
80106a81:	75 18                	jne    80106a9b <trap+0x8a>
    {
      cprintf("Unhandled page fault for va:0x%x!\n", faulting_va);     // CS 3320 project 2
80106a83:	83 ec 08             	sub    $0x8,%esp
80106a86:	ff 75 e4             	push   -0x1c(%ebp)
80106a89:	68 94 8d 10 80       	push   $0x80108d94
80106a8e:	e8 31 99 ff ff       	call   801003c4 <cprintf>
80106a93:	83 c4 10             	add    $0x10,%esp
80106a96:	e9 a5 00 00 00       	jmp    80106b40 <trap+0x12f>
    }
    else if(page_allocator_type == 1)
80106a9b:	a1 60 19 11 80       	mov    0x80111960,%eax
80106aa0:	83 f8 01             	cmp    $0x1,%eax
80106aa3:	0f 85 97 00 00 00    	jne    80106b40 <trap+0x12f>
    {  
      if(faulting_va > proc->sz) // If the page fault is beyond the virtual size 
80106aa9:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106aaf:	8b 00                	mov    (%eax),%eax
80106ab1:	3b 45 e4             	cmp    -0x1c(%ebp),%eax
80106ab4:	73 15                	jae    80106acb <trap+0xba>
      {
        // it is a true invalid access and we should kill the process
        cprintf("Unhandled page fault for va:0x%x!\n", faulting_va);
80106ab6:	83 ec 08             	sub    $0x8,%esp
80106ab9:	ff 75 e4             	push   -0x1c(%ebp)
80106abc:	68 94 8d 10 80       	push   $0x80108d94
80106ac1:	e8 fe 98 ff ff       	call   801003c4 <cprintf>
80106ac6:	83 c4 10             	add    $0x10,%esp
80106ac9:	eb 75                	jmp    80106b40 <trap+0x12f>
      }
      else
      {
        char *mem;
        uint bound = PGROUNDDOWN(faulting_va);
80106acb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106ace:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80106ad3:	89 45 e0             	mov    %eax,-0x20(%ebp)
        mem = kalloc();
80106ad6:	e8 ab c1 ff ff       	call   80102c86 <kalloc>
80106adb:	89 45 dc             	mov    %eax,-0x24(%ebp)
        if (mem == 0) // If we run out of memory
80106ade:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
80106ae2:	75 12                	jne    80106af6 <trap+0xe5>
        {
          cprintf("Lazy allocator out of memory!\n");
80106ae4:	83 ec 0c             	sub    $0xc,%esp
80106ae7:	68 b8 8d 10 80       	push   $0x80108db8
80106aec:	e8 d3 98 ff ff       	call   801003c4 <cprintf>
80106af1:	83 c4 10             	add    $0x10,%esp
80106af4:	eb 4a                	jmp    80106b40 <trap+0x12f>
        }
        else
        {
          memset(mem, 0, PGSIZE);
80106af6:	83 ec 04             	sub    $0x4,%esp
80106af9:	68 00 10 00 00       	push   $0x1000
80106afe:	6a 00                	push   $0x0
80106b00:	ff 75 dc             	push   -0x24(%ebp)
80106b03:	e8 db e7 ff ff       	call   801052e3 <memset>
80106b08:	83 c4 10             	add    $0x10,%esp
          mappages(proc->pgdir, (char*)bound, PGSIZE, v2p(mem), PTE_W|PTE_U);
80106b0b:	83 ec 0c             	sub    $0xc,%esp
80106b0e:	ff 75 dc             	push   -0x24(%ebp)
80106b11:	e8 25 fd ff ff       	call   8010683b <v2p>
80106b16:	83 c4 10             	add    $0x10,%esp
80106b19:	8b 4d e0             	mov    -0x20(%ebp),%ecx
80106b1c:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
80106b23:	8b 52 04             	mov    0x4(%edx),%edx
80106b26:	83 ec 0c             	sub    $0xc,%esp
80106b29:	6a 06                	push   $0x6
80106b2b:	50                   	push   %eax
80106b2c:	68 00 10 00 00       	push   $0x1000
80106b31:	51                   	push   %ecx
80106b32:	52                   	push   %edx
80106b33:	e8 18 14 00 00       	call   80107f50 <mappages>
80106b38:	83 c4 20             	add    $0x20,%esp
          return;
80106b3b:	e9 13 02 00 00       	jmp    80106d53 <trap+0x342>
      }
    }
 }


  switch(tf->trapno){
80106b40:	8b 45 08             	mov    0x8(%ebp),%eax
80106b43:	8b 40 30             	mov    0x30(%eax),%eax
80106b46:	83 e8 20             	sub    $0x20,%eax
80106b49:	83 f8 1f             	cmp    $0x1f,%eax
80106b4c:	0f 87 c0 00 00 00    	ja     80106c12 <trap+0x201>
80106b52:	8b 04 85 78 8e 10 80 	mov    -0x7fef7188(,%eax,4),%eax
80106b59:	ff e0                	jmp    *%eax
  case T_IRQ0 + IRQ_TIMER:
    if(cpu->id == 0){
80106b5b:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80106b61:	0f b6 00             	movzbl (%eax),%eax
80106b64:	84 c0                	test   %al,%al
80106b66:	75 3d                	jne    80106ba5 <trap+0x194>
      acquire(&tickslock);
80106b68:	83 ec 0c             	sub    $0xc,%esp
80106b6b:	68 c0 40 11 80       	push   $0x801140c0
80106b70:	e8 0a e5 ff ff       	call   8010507f <acquire>
80106b75:	83 c4 10             	add    $0x10,%esp
      ticks++;
80106b78:	a1 f4 40 11 80       	mov    0x801140f4,%eax
80106b7d:	83 c0 01             	add    $0x1,%eax
80106b80:	a3 f4 40 11 80       	mov    %eax,0x801140f4
      wakeup(&ticks);
80106b85:	83 ec 0c             	sub    $0xc,%esp
80106b88:	68 f4 40 11 80       	push   $0x801140f4
80106b8d:	e8 de e2 ff ff       	call   80104e70 <wakeup>
80106b92:	83 c4 10             	add    $0x10,%esp
      release(&tickslock);
80106b95:	83 ec 0c             	sub    $0xc,%esp
80106b98:	68 c0 40 11 80       	push   $0x801140c0
80106b9d:	e8 44 e5 ff ff       	call   801050e6 <release>
80106ba2:	83 c4 10             	add    $0x10,%esp
    }
    lapiceoi();
80106ba5:	e8 a6 c4 ff ff       	call   80103050 <lapiceoi>
    break;
80106baa:	e9 1d 01 00 00       	jmp    80106ccc <trap+0x2bb>
  case T_IRQ0 + IRQ_IDE:
    ideintr();
80106baf:	e8 96 bc ff ff       	call   8010284a <ideintr>
    lapiceoi();
80106bb4:	e8 97 c4 ff ff       	call   80103050 <lapiceoi>
    break;
80106bb9:	e9 0e 01 00 00       	jmp    80106ccc <trap+0x2bb>
  case T_IRQ0 + IRQ_IDE+1:
    // Bochs generates spurious IDE1 interrupts.
    break;
  case T_IRQ0 + IRQ_KBD:
    kbdintr();
80106bbe:	e8 91 c2 ff ff       	call   80102e54 <kbdintr>
    lapiceoi();
80106bc3:	e8 88 c4 ff ff       	call   80103050 <lapiceoi>
    break;
80106bc8:	e9 ff 00 00 00       	jmp    80106ccc <trap+0x2bb>
  case T_IRQ0 + IRQ_COM1:
    uartintr();
80106bcd:	e8 61 03 00 00       	call   80106f33 <uartintr>
    lapiceoi();
80106bd2:	e8 79 c4 ff ff       	call   80103050 <lapiceoi>
    break;
80106bd7:	e9 f0 00 00 00       	jmp    80106ccc <trap+0x2bb>
  case T_IRQ0 + 7:
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
80106bdc:	8b 45 08             	mov    0x8(%ebp),%eax
80106bdf:	8b 48 38             	mov    0x38(%eax),%ecx
            cpu->id, tf->cs, tf->eip);
80106be2:	8b 45 08             	mov    0x8(%ebp),%eax
80106be5:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
80106be9:	0f b7 d0             	movzwl %ax,%edx
            cpu->id, tf->cs, tf->eip);
80106bec:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80106bf2:	0f b6 00             	movzbl (%eax),%eax
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
80106bf5:	0f b6 c0             	movzbl %al,%eax
80106bf8:	51                   	push   %ecx
80106bf9:	52                   	push   %edx
80106bfa:	50                   	push   %eax
80106bfb:	68 d8 8d 10 80       	push   $0x80108dd8
80106c00:	e8 bf 97 ff ff       	call   801003c4 <cprintf>
80106c05:	83 c4 10             	add    $0x10,%esp
    lapiceoi();
80106c08:	e8 43 c4 ff ff       	call   80103050 <lapiceoi>
    break;
80106c0d:	e9 ba 00 00 00       	jmp    80106ccc <trap+0x2bb>
   
  //PAGEBREAK: 13
  default:
    if(proc == 0 || (tf->cs&3) == 0){
80106c12:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106c18:	85 c0                	test   %eax,%eax
80106c1a:	74 11                	je     80106c2d <trap+0x21c>
80106c1c:	8b 45 08             	mov    0x8(%ebp),%eax
80106c1f:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
80106c23:	0f b7 c0             	movzwl %ax,%eax
80106c26:	83 e0 03             	and    $0x3,%eax
80106c29:	85 c0                	test   %eax,%eax
80106c2b:	75 3f                	jne    80106c6c <trap+0x25b>
      // In kernel, it must be our mistake.
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
80106c2d:	e8 40 fc ff ff       	call   80106872 <rcr2>
80106c32:	8b 55 08             	mov    0x8(%ebp),%edx
80106c35:	8b 5a 38             	mov    0x38(%edx),%ebx
              tf->trapno, cpu->id, tf->eip, rcr2());
80106c38:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80106c3f:	0f b6 12             	movzbl (%edx),%edx
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
80106c42:	0f b6 ca             	movzbl %dl,%ecx
80106c45:	8b 55 08             	mov    0x8(%ebp),%edx
80106c48:	8b 52 30             	mov    0x30(%edx),%edx
80106c4b:	83 ec 0c             	sub    $0xc,%esp
80106c4e:	50                   	push   %eax
80106c4f:	53                   	push   %ebx
80106c50:	51                   	push   %ecx
80106c51:	52                   	push   %edx
80106c52:	68 fc 8d 10 80       	push   $0x80108dfc
80106c57:	e8 68 97 ff ff       	call   801003c4 <cprintf>
80106c5c:	83 c4 20             	add    $0x20,%esp
      panic("trap");
80106c5f:	83 ec 0c             	sub    $0xc,%esp
80106c62:	68 2e 8e 10 80       	push   $0x80108e2e
80106c67:	e8 0d 99 ff ff       	call   80100579 <panic>
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80106c6c:	e8 01 fc ff ff       	call   80106872 <rcr2>
80106c71:	89 c2                	mov    %eax,%edx
80106c73:	8b 45 08             	mov    0x8(%ebp),%eax
80106c76:	8b 78 38             	mov    0x38(%eax),%edi
            "eip 0x%x addr 0x%x--kill proc\n",
            proc->pid, proc->name, tf->trapno, tf->err, cpu->id, tf->eip, 
80106c79:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80106c7f:	0f b6 00             	movzbl (%eax),%eax
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80106c82:	0f b6 f0             	movzbl %al,%esi
80106c85:	8b 45 08             	mov    0x8(%ebp),%eax
80106c88:	8b 58 34             	mov    0x34(%eax),%ebx
80106c8b:	8b 45 08             	mov    0x8(%ebp),%eax
80106c8e:	8b 48 30             	mov    0x30(%eax),%ecx
            proc->pid, proc->name, tf->trapno, tf->err, cpu->id, tf->eip, 
80106c91:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106c97:	83 c0 6c             	add    $0x6c,%eax
80106c9a:	89 45 d4             	mov    %eax,-0x2c(%ebp)
80106c9d:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80106ca3:	8b 40 10             	mov    0x10(%eax),%eax
80106ca6:	52                   	push   %edx
80106ca7:	57                   	push   %edi
80106ca8:	56                   	push   %esi
80106ca9:	53                   	push   %ebx
80106caa:	51                   	push   %ecx
80106cab:	ff 75 d4             	push   -0x2c(%ebp)
80106cae:	50                   	push   %eax
80106caf:	68 34 8e 10 80       	push   $0x80108e34
80106cb4:	e8 0b 97 ff ff       	call   801003c4 <cprintf>
80106cb9:	83 c4 20             	add    $0x20,%esp
            rcr2());
    proc->killed = 1;
80106cbc:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106cc2:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
80106cc9:	eb 01                	jmp    80106ccc <trap+0x2bb>
    break;
80106ccb:	90                   	nop
  }

  // Force process exit if it has been killed and is in user space.
  // (If it is still executing in the kernel, let it keep running 
  // until it gets to the regular system call return.)
  if(proc && proc->killed && (tf->cs&3) == DPL_USER)
80106ccc:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106cd2:	85 c0                	test   %eax,%eax
80106cd4:	74 24                	je     80106cfa <trap+0x2e9>
80106cd6:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106cdc:	8b 40 24             	mov    0x24(%eax),%eax
80106cdf:	85 c0                	test   %eax,%eax
80106ce1:	74 17                	je     80106cfa <trap+0x2e9>
80106ce3:	8b 45 08             	mov    0x8(%ebp),%eax
80106ce6:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
80106cea:	0f b7 c0             	movzwl %ax,%eax
80106ced:	83 e0 03             	and    $0x3,%eax
80106cf0:	83 f8 03             	cmp    $0x3,%eax
80106cf3:	75 05                	jne    80106cfa <trap+0x2e9>
    exit();
80106cf5:	e8 28 dc ff ff       	call   80104922 <exit>

  // Force process to give up CPU on clock tick.
  // If interrupts were on while locks held, would need to check nlock.
  if(proc && proc->state == RUNNING && tf->trapno == T_IRQ0+IRQ_TIMER)
80106cfa:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106d00:	85 c0                	test   %eax,%eax
80106d02:	74 1e                	je     80106d22 <trap+0x311>
80106d04:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106d0a:	8b 40 0c             	mov    0xc(%eax),%eax
80106d0d:	83 f8 04             	cmp    $0x4,%eax
80106d10:	75 10                	jne    80106d22 <trap+0x311>
80106d12:	8b 45 08             	mov    0x8(%ebp),%eax
80106d15:	8b 40 30             	mov    0x30(%eax),%eax
80106d18:	83 f8 20             	cmp    $0x20,%eax
80106d1b:	75 05                	jne    80106d22 <trap+0x311>
    yield();
80106d1d:	e8 e1 df ff ff       	call   80104d03 <yield>

  // Check if the process has been killed since we yielded
  if(proc && proc->killed && (tf->cs&3) == DPL_USER)
80106d22:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106d28:	85 c0                	test   %eax,%eax
80106d2a:	74 27                	je     80106d53 <trap+0x342>
80106d2c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106d32:	8b 40 24             	mov    0x24(%eax),%eax
80106d35:	85 c0                	test   %eax,%eax
80106d37:	74 1a                	je     80106d53 <trap+0x342>
80106d39:	8b 45 08             	mov    0x8(%ebp),%eax
80106d3c:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
80106d40:	0f b7 c0             	movzwl %ax,%eax
80106d43:	83 e0 03             	and    $0x3,%eax
80106d46:	83 f8 03             	cmp    $0x3,%eax
80106d49:	75 08                	jne    80106d53 <trap+0x342>
    exit();
80106d4b:	e8 d2 db ff ff       	call   80104922 <exit>
80106d50:	eb 01                	jmp    80106d53 <trap+0x342>
    return;
80106d52:	90                   	nop
}
80106d53:	8d 65 f4             	lea    -0xc(%ebp),%esp
80106d56:	5b                   	pop    %ebx
80106d57:	5e                   	pop    %esi
80106d58:	5f                   	pop    %edi
80106d59:	5d                   	pop    %ebp
80106d5a:	c3                   	ret

80106d5b <inb>:
{
80106d5b:	55                   	push   %ebp
80106d5c:	89 e5                	mov    %esp,%ebp
80106d5e:	83 ec 14             	sub    $0x14,%esp
80106d61:	8b 45 08             	mov    0x8(%ebp),%eax
80106d64:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80106d68:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80106d6c:	89 c2                	mov    %eax,%edx
80106d6e:	ec                   	in     (%dx),%al
80106d6f:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80106d72:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80106d76:	c9                   	leave
80106d77:	c3                   	ret

80106d78 <outb>:
{
80106d78:	55                   	push   %ebp
80106d79:	89 e5                	mov    %esp,%ebp
80106d7b:	83 ec 08             	sub    $0x8,%esp
80106d7e:	8b 55 08             	mov    0x8(%ebp),%edx
80106d81:	8b 45 0c             	mov    0xc(%ebp),%eax
80106d84:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80106d88:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80106d8b:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80106d8f:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80106d93:	ee                   	out    %al,(%dx)
}
80106d94:	90                   	nop
80106d95:	c9                   	leave
80106d96:	c3                   	ret

80106d97 <uartinit>:

static int uart;    // is there a uart?

void
uartinit(void)
{
80106d97:	55                   	push   %ebp
80106d98:	89 e5                	mov    %esp,%ebp
80106d9a:	83 ec 18             	sub    $0x18,%esp
  char *p;

  // Turn off the FIFO
  outb(COM1+2, 0);
80106d9d:	6a 00                	push   $0x0
80106d9f:	68 fa 03 00 00       	push   $0x3fa
80106da4:	e8 cf ff ff ff       	call   80106d78 <outb>
80106da9:	83 c4 08             	add    $0x8,%esp
  
  // 9600 baud, 8 data bits, 1 stop bit, parity off.
  outb(COM1+3, 0x80);    // Unlock divisor
80106dac:	68 80 00 00 00       	push   $0x80
80106db1:	68 fb 03 00 00       	push   $0x3fb
80106db6:	e8 bd ff ff ff       	call   80106d78 <outb>
80106dbb:	83 c4 08             	add    $0x8,%esp
  outb(COM1+0, 115200/9600);
80106dbe:	6a 0c                	push   $0xc
80106dc0:	68 f8 03 00 00       	push   $0x3f8
80106dc5:	e8 ae ff ff ff       	call   80106d78 <outb>
80106dca:	83 c4 08             	add    $0x8,%esp
  outb(COM1+1, 0);
80106dcd:	6a 00                	push   $0x0
80106dcf:	68 f9 03 00 00       	push   $0x3f9
80106dd4:	e8 9f ff ff ff       	call   80106d78 <outb>
80106dd9:	83 c4 08             	add    $0x8,%esp
  outb(COM1+3, 0x03);    // Lock divisor, 8 data bits.
80106ddc:	6a 03                	push   $0x3
80106dde:	68 fb 03 00 00       	push   $0x3fb
80106de3:	e8 90 ff ff ff       	call   80106d78 <outb>
80106de8:	83 c4 08             	add    $0x8,%esp
  outb(COM1+4, 0);
80106deb:	6a 00                	push   $0x0
80106ded:	68 fc 03 00 00       	push   $0x3fc
80106df2:	e8 81 ff ff ff       	call   80106d78 <outb>
80106df7:	83 c4 08             	add    $0x8,%esp
  outb(COM1+1, 0x01);    // Enable receive interrupts.
80106dfa:	6a 01                	push   $0x1
80106dfc:	68 f9 03 00 00       	push   $0x3f9
80106e01:	e8 72 ff ff ff       	call   80106d78 <outb>
80106e06:	83 c4 08             	add    $0x8,%esp

  // If status is 0xFF, no serial port.
  if(inb(COM1+5) == 0xFF)
80106e09:	68 fd 03 00 00       	push   $0x3fd
80106e0e:	e8 48 ff ff ff       	call   80106d5b <inb>
80106e13:	83 c4 04             	add    $0x4,%esp
80106e16:	3c ff                	cmp    $0xff,%al
80106e18:	74 6e                	je     80106e88 <uartinit+0xf1>
    return;
  uart = 1;
80106e1a:	c7 05 f8 40 11 80 01 	movl   $0x1,0x801140f8
80106e21:	00 00 00 

  // Acknowledge pre-existing interrupt conditions;
  // enable interrupts.
  inb(COM1+2);
80106e24:	68 fa 03 00 00       	push   $0x3fa
80106e29:	e8 2d ff ff ff       	call   80106d5b <inb>
80106e2e:	83 c4 04             	add    $0x4,%esp
  inb(COM1+0);
80106e31:	68 f8 03 00 00       	push   $0x3f8
80106e36:	e8 20 ff ff ff       	call   80106d5b <inb>
80106e3b:	83 c4 04             	add    $0x4,%esp
  picenable(IRQ_COM1);
80106e3e:	83 ec 0c             	sub    $0xc,%esp
80106e41:	6a 04                	push   $0x4
80106e43:	e8 20 d1 ff ff       	call   80103f68 <picenable>
80106e48:	83 c4 10             	add    $0x10,%esp
  ioapicenable(IRQ_COM1, 0);
80106e4b:	83 ec 08             	sub    $0x8,%esp
80106e4e:	6a 00                	push   $0x0
80106e50:	6a 04                	push   $0x4
80106e52:	e8 95 bc ff ff       	call   80102aec <ioapicenable>
80106e57:	83 c4 10             	add    $0x10,%esp
  
  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
80106e5a:	c7 45 f4 f8 8e 10 80 	movl   $0x80108ef8,-0xc(%ebp)
80106e61:	eb 19                	jmp    80106e7c <uartinit+0xe5>
    uartputc(*p);
80106e63:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106e66:	0f b6 00             	movzbl (%eax),%eax
80106e69:	0f be c0             	movsbl %al,%eax
80106e6c:	83 ec 0c             	sub    $0xc,%esp
80106e6f:	50                   	push   %eax
80106e70:	e8 16 00 00 00       	call   80106e8b <uartputc>
80106e75:	83 c4 10             	add    $0x10,%esp
  for(p="xv6...\n"; *p; p++)
80106e78:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80106e7c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106e7f:	0f b6 00             	movzbl (%eax),%eax
80106e82:	84 c0                	test   %al,%al
80106e84:	75 dd                	jne    80106e63 <uartinit+0xcc>
80106e86:	eb 01                	jmp    80106e89 <uartinit+0xf2>
    return;
80106e88:	90                   	nop
}
80106e89:	c9                   	leave
80106e8a:	c3                   	ret

80106e8b <uartputc>:

void
uartputc(int c)
{
80106e8b:	55                   	push   %ebp
80106e8c:	89 e5                	mov    %esp,%ebp
80106e8e:	83 ec 18             	sub    $0x18,%esp
  int i;

  if(!uart)
80106e91:	a1 f8 40 11 80       	mov    0x801140f8,%eax
80106e96:	85 c0                	test   %eax,%eax
80106e98:	74 53                	je     80106eed <uartputc+0x62>
    return;
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
80106e9a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80106ea1:	eb 11                	jmp    80106eb4 <uartputc+0x29>
    microdelay(10);
80106ea3:	83 ec 0c             	sub    $0xc,%esp
80106ea6:	6a 0a                	push   $0xa
80106ea8:	e8 be c1 ff ff       	call   8010306b <microdelay>
80106ead:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
80106eb0:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80106eb4:	83 7d f4 7f          	cmpl   $0x7f,-0xc(%ebp)
80106eb8:	7f 1a                	jg     80106ed4 <uartputc+0x49>
80106eba:	83 ec 0c             	sub    $0xc,%esp
80106ebd:	68 fd 03 00 00       	push   $0x3fd
80106ec2:	e8 94 fe ff ff       	call   80106d5b <inb>
80106ec7:	83 c4 10             	add    $0x10,%esp
80106eca:	0f b6 c0             	movzbl %al,%eax
80106ecd:	83 e0 20             	and    $0x20,%eax
80106ed0:	85 c0                	test   %eax,%eax
80106ed2:	74 cf                	je     80106ea3 <uartputc+0x18>
  outb(COM1+0, c);
80106ed4:	8b 45 08             	mov    0x8(%ebp),%eax
80106ed7:	0f b6 c0             	movzbl %al,%eax
80106eda:	83 ec 08             	sub    $0x8,%esp
80106edd:	50                   	push   %eax
80106ede:	68 f8 03 00 00       	push   $0x3f8
80106ee3:	e8 90 fe ff ff       	call   80106d78 <outb>
80106ee8:	83 c4 10             	add    $0x10,%esp
80106eeb:	eb 01                	jmp    80106eee <uartputc+0x63>
    return;
80106eed:	90                   	nop
}
80106eee:	c9                   	leave
80106eef:	c3                   	ret

80106ef0 <uartgetc>:

static int
uartgetc(void)
{
80106ef0:	55                   	push   %ebp
80106ef1:	89 e5                	mov    %esp,%ebp
  if(!uart)
80106ef3:	a1 f8 40 11 80       	mov    0x801140f8,%eax
80106ef8:	85 c0                	test   %eax,%eax
80106efa:	75 07                	jne    80106f03 <uartgetc+0x13>
    return -1;
80106efc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106f01:	eb 2e                	jmp    80106f31 <uartgetc+0x41>
  if(!(inb(COM1+5) & 0x01))
80106f03:	68 fd 03 00 00       	push   $0x3fd
80106f08:	e8 4e fe ff ff       	call   80106d5b <inb>
80106f0d:	83 c4 04             	add    $0x4,%esp
80106f10:	0f b6 c0             	movzbl %al,%eax
80106f13:	83 e0 01             	and    $0x1,%eax
80106f16:	85 c0                	test   %eax,%eax
80106f18:	75 07                	jne    80106f21 <uartgetc+0x31>
    return -1;
80106f1a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106f1f:	eb 10                	jmp    80106f31 <uartgetc+0x41>
  return inb(COM1+0);
80106f21:	68 f8 03 00 00       	push   $0x3f8
80106f26:	e8 30 fe ff ff       	call   80106d5b <inb>
80106f2b:	83 c4 04             	add    $0x4,%esp
80106f2e:	0f b6 c0             	movzbl %al,%eax
}
80106f31:	c9                   	leave
80106f32:	c3                   	ret

80106f33 <uartintr>:

void
uartintr(void)
{
80106f33:	55                   	push   %ebp
80106f34:	89 e5                	mov    %esp,%ebp
80106f36:	83 ec 08             	sub    $0x8,%esp
  consoleintr(uartgetc);
80106f39:	83 ec 0c             	sub    $0xc,%esp
80106f3c:	68 f0 6e 10 80       	push   $0x80106ef0
80106f41:	e8 d0 98 ff ff       	call   80100816 <consoleintr>
80106f46:	83 c4 10             	add    $0x10,%esp
}
80106f49:	90                   	nop
80106f4a:	c9                   	leave
80106f4b:	c3                   	ret

80106f4c <vector0>:
# generated by vectors.pl - do not edit
# handlers
.globl alltraps
.globl vector0
vector0:
  pushl $0
80106f4c:	6a 00                	push   $0x0
  pushl $0
80106f4e:	6a 00                	push   $0x0
  jmp alltraps
80106f50:	e9 bb f8 ff ff       	jmp    80106810 <alltraps>

80106f55 <vector1>:
.globl vector1
vector1:
  pushl $0
80106f55:	6a 00                	push   $0x0
  pushl $1
80106f57:	6a 01                	push   $0x1
  jmp alltraps
80106f59:	e9 b2 f8 ff ff       	jmp    80106810 <alltraps>

80106f5e <vector2>:
.globl vector2
vector2:
  pushl $0
80106f5e:	6a 00                	push   $0x0
  pushl $2
80106f60:	6a 02                	push   $0x2
  jmp alltraps
80106f62:	e9 a9 f8 ff ff       	jmp    80106810 <alltraps>

80106f67 <vector3>:
.globl vector3
vector3:
  pushl $0
80106f67:	6a 00                	push   $0x0
  pushl $3
80106f69:	6a 03                	push   $0x3
  jmp alltraps
80106f6b:	e9 a0 f8 ff ff       	jmp    80106810 <alltraps>

80106f70 <vector4>:
.globl vector4
vector4:
  pushl $0
80106f70:	6a 00                	push   $0x0
  pushl $4
80106f72:	6a 04                	push   $0x4
  jmp alltraps
80106f74:	e9 97 f8 ff ff       	jmp    80106810 <alltraps>

80106f79 <vector5>:
.globl vector5
vector5:
  pushl $0
80106f79:	6a 00                	push   $0x0
  pushl $5
80106f7b:	6a 05                	push   $0x5
  jmp alltraps
80106f7d:	e9 8e f8 ff ff       	jmp    80106810 <alltraps>

80106f82 <vector6>:
.globl vector6
vector6:
  pushl $0
80106f82:	6a 00                	push   $0x0
  pushl $6
80106f84:	6a 06                	push   $0x6
  jmp alltraps
80106f86:	e9 85 f8 ff ff       	jmp    80106810 <alltraps>

80106f8b <vector7>:
.globl vector7
vector7:
  pushl $0
80106f8b:	6a 00                	push   $0x0
  pushl $7
80106f8d:	6a 07                	push   $0x7
  jmp alltraps
80106f8f:	e9 7c f8 ff ff       	jmp    80106810 <alltraps>

80106f94 <vector8>:
.globl vector8
vector8:
  pushl $8
80106f94:	6a 08                	push   $0x8
  jmp alltraps
80106f96:	e9 75 f8 ff ff       	jmp    80106810 <alltraps>

80106f9b <vector9>:
.globl vector9
vector9:
  pushl $0
80106f9b:	6a 00                	push   $0x0
  pushl $9
80106f9d:	6a 09                	push   $0x9
  jmp alltraps
80106f9f:	e9 6c f8 ff ff       	jmp    80106810 <alltraps>

80106fa4 <vector10>:
.globl vector10
vector10:
  pushl $10
80106fa4:	6a 0a                	push   $0xa
  jmp alltraps
80106fa6:	e9 65 f8 ff ff       	jmp    80106810 <alltraps>

80106fab <vector11>:
.globl vector11
vector11:
  pushl $11
80106fab:	6a 0b                	push   $0xb
  jmp alltraps
80106fad:	e9 5e f8 ff ff       	jmp    80106810 <alltraps>

80106fb2 <vector12>:
.globl vector12
vector12:
  pushl $12
80106fb2:	6a 0c                	push   $0xc
  jmp alltraps
80106fb4:	e9 57 f8 ff ff       	jmp    80106810 <alltraps>

80106fb9 <vector13>:
.globl vector13
vector13:
  pushl $13
80106fb9:	6a 0d                	push   $0xd
  jmp alltraps
80106fbb:	e9 50 f8 ff ff       	jmp    80106810 <alltraps>

80106fc0 <vector14>:
.globl vector14
vector14:
  pushl $14
80106fc0:	6a 0e                	push   $0xe
  jmp alltraps
80106fc2:	e9 49 f8 ff ff       	jmp    80106810 <alltraps>

80106fc7 <vector15>:
.globl vector15
vector15:
  pushl $0
80106fc7:	6a 00                	push   $0x0
  pushl $15
80106fc9:	6a 0f                	push   $0xf
  jmp alltraps
80106fcb:	e9 40 f8 ff ff       	jmp    80106810 <alltraps>

80106fd0 <vector16>:
.globl vector16
vector16:
  pushl $0
80106fd0:	6a 00                	push   $0x0
  pushl $16
80106fd2:	6a 10                	push   $0x10
  jmp alltraps
80106fd4:	e9 37 f8 ff ff       	jmp    80106810 <alltraps>

80106fd9 <vector17>:
.globl vector17
vector17:
  pushl $17
80106fd9:	6a 11                	push   $0x11
  jmp alltraps
80106fdb:	e9 30 f8 ff ff       	jmp    80106810 <alltraps>

80106fe0 <vector18>:
.globl vector18
vector18:
  pushl $0
80106fe0:	6a 00                	push   $0x0
  pushl $18
80106fe2:	6a 12                	push   $0x12
  jmp alltraps
80106fe4:	e9 27 f8 ff ff       	jmp    80106810 <alltraps>

80106fe9 <vector19>:
.globl vector19
vector19:
  pushl $0
80106fe9:	6a 00                	push   $0x0
  pushl $19
80106feb:	6a 13                	push   $0x13
  jmp alltraps
80106fed:	e9 1e f8 ff ff       	jmp    80106810 <alltraps>

80106ff2 <vector20>:
.globl vector20
vector20:
  pushl $0
80106ff2:	6a 00                	push   $0x0
  pushl $20
80106ff4:	6a 14                	push   $0x14
  jmp alltraps
80106ff6:	e9 15 f8 ff ff       	jmp    80106810 <alltraps>

80106ffb <vector21>:
.globl vector21
vector21:
  pushl $0
80106ffb:	6a 00                	push   $0x0
  pushl $21
80106ffd:	6a 15                	push   $0x15
  jmp alltraps
80106fff:	e9 0c f8 ff ff       	jmp    80106810 <alltraps>

80107004 <vector22>:
.globl vector22
vector22:
  pushl $0
80107004:	6a 00                	push   $0x0
  pushl $22
80107006:	6a 16                	push   $0x16
  jmp alltraps
80107008:	e9 03 f8 ff ff       	jmp    80106810 <alltraps>

8010700d <vector23>:
.globl vector23
vector23:
  pushl $0
8010700d:	6a 00                	push   $0x0
  pushl $23
8010700f:	6a 17                	push   $0x17
  jmp alltraps
80107011:	e9 fa f7 ff ff       	jmp    80106810 <alltraps>

80107016 <vector24>:
.globl vector24
vector24:
  pushl $0
80107016:	6a 00                	push   $0x0
  pushl $24
80107018:	6a 18                	push   $0x18
  jmp alltraps
8010701a:	e9 f1 f7 ff ff       	jmp    80106810 <alltraps>

8010701f <vector25>:
.globl vector25
vector25:
  pushl $0
8010701f:	6a 00                	push   $0x0
  pushl $25
80107021:	6a 19                	push   $0x19
  jmp alltraps
80107023:	e9 e8 f7 ff ff       	jmp    80106810 <alltraps>

80107028 <vector26>:
.globl vector26
vector26:
  pushl $0
80107028:	6a 00                	push   $0x0
  pushl $26
8010702a:	6a 1a                	push   $0x1a
  jmp alltraps
8010702c:	e9 df f7 ff ff       	jmp    80106810 <alltraps>

80107031 <vector27>:
.globl vector27
vector27:
  pushl $0
80107031:	6a 00                	push   $0x0
  pushl $27
80107033:	6a 1b                	push   $0x1b
  jmp alltraps
80107035:	e9 d6 f7 ff ff       	jmp    80106810 <alltraps>

8010703a <vector28>:
.globl vector28
vector28:
  pushl $0
8010703a:	6a 00                	push   $0x0
  pushl $28
8010703c:	6a 1c                	push   $0x1c
  jmp alltraps
8010703e:	e9 cd f7 ff ff       	jmp    80106810 <alltraps>

80107043 <vector29>:
.globl vector29
vector29:
  pushl $0
80107043:	6a 00                	push   $0x0
  pushl $29
80107045:	6a 1d                	push   $0x1d
  jmp alltraps
80107047:	e9 c4 f7 ff ff       	jmp    80106810 <alltraps>

8010704c <vector30>:
.globl vector30
vector30:
  pushl $0
8010704c:	6a 00                	push   $0x0
  pushl $30
8010704e:	6a 1e                	push   $0x1e
  jmp alltraps
80107050:	e9 bb f7 ff ff       	jmp    80106810 <alltraps>

80107055 <vector31>:
.globl vector31
vector31:
  pushl $0
80107055:	6a 00                	push   $0x0
  pushl $31
80107057:	6a 1f                	push   $0x1f
  jmp alltraps
80107059:	e9 b2 f7 ff ff       	jmp    80106810 <alltraps>

8010705e <vector32>:
.globl vector32
vector32:
  pushl $0
8010705e:	6a 00                	push   $0x0
  pushl $32
80107060:	6a 20                	push   $0x20
  jmp alltraps
80107062:	e9 a9 f7 ff ff       	jmp    80106810 <alltraps>

80107067 <vector33>:
.globl vector33
vector33:
  pushl $0
80107067:	6a 00                	push   $0x0
  pushl $33
80107069:	6a 21                	push   $0x21
  jmp alltraps
8010706b:	e9 a0 f7 ff ff       	jmp    80106810 <alltraps>

80107070 <vector34>:
.globl vector34
vector34:
  pushl $0
80107070:	6a 00                	push   $0x0
  pushl $34
80107072:	6a 22                	push   $0x22
  jmp alltraps
80107074:	e9 97 f7 ff ff       	jmp    80106810 <alltraps>

80107079 <vector35>:
.globl vector35
vector35:
  pushl $0
80107079:	6a 00                	push   $0x0
  pushl $35
8010707b:	6a 23                	push   $0x23
  jmp alltraps
8010707d:	e9 8e f7 ff ff       	jmp    80106810 <alltraps>

80107082 <vector36>:
.globl vector36
vector36:
  pushl $0
80107082:	6a 00                	push   $0x0
  pushl $36
80107084:	6a 24                	push   $0x24
  jmp alltraps
80107086:	e9 85 f7 ff ff       	jmp    80106810 <alltraps>

8010708b <vector37>:
.globl vector37
vector37:
  pushl $0
8010708b:	6a 00                	push   $0x0
  pushl $37
8010708d:	6a 25                	push   $0x25
  jmp alltraps
8010708f:	e9 7c f7 ff ff       	jmp    80106810 <alltraps>

80107094 <vector38>:
.globl vector38
vector38:
  pushl $0
80107094:	6a 00                	push   $0x0
  pushl $38
80107096:	6a 26                	push   $0x26
  jmp alltraps
80107098:	e9 73 f7 ff ff       	jmp    80106810 <alltraps>

8010709d <vector39>:
.globl vector39
vector39:
  pushl $0
8010709d:	6a 00                	push   $0x0
  pushl $39
8010709f:	6a 27                	push   $0x27
  jmp alltraps
801070a1:	e9 6a f7 ff ff       	jmp    80106810 <alltraps>

801070a6 <vector40>:
.globl vector40
vector40:
  pushl $0
801070a6:	6a 00                	push   $0x0
  pushl $40
801070a8:	6a 28                	push   $0x28
  jmp alltraps
801070aa:	e9 61 f7 ff ff       	jmp    80106810 <alltraps>

801070af <vector41>:
.globl vector41
vector41:
  pushl $0
801070af:	6a 00                	push   $0x0
  pushl $41
801070b1:	6a 29                	push   $0x29
  jmp alltraps
801070b3:	e9 58 f7 ff ff       	jmp    80106810 <alltraps>

801070b8 <vector42>:
.globl vector42
vector42:
  pushl $0
801070b8:	6a 00                	push   $0x0
  pushl $42
801070ba:	6a 2a                	push   $0x2a
  jmp alltraps
801070bc:	e9 4f f7 ff ff       	jmp    80106810 <alltraps>

801070c1 <vector43>:
.globl vector43
vector43:
  pushl $0
801070c1:	6a 00                	push   $0x0
  pushl $43
801070c3:	6a 2b                	push   $0x2b
  jmp alltraps
801070c5:	e9 46 f7 ff ff       	jmp    80106810 <alltraps>

801070ca <vector44>:
.globl vector44
vector44:
  pushl $0
801070ca:	6a 00                	push   $0x0
  pushl $44
801070cc:	6a 2c                	push   $0x2c
  jmp alltraps
801070ce:	e9 3d f7 ff ff       	jmp    80106810 <alltraps>

801070d3 <vector45>:
.globl vector45
vector45:
  pushl $0
801070d3:	6a 00                	push   $0x0
  pushl $45
801070d5:	6a 2d                	push   $0x2d
  jmp alltraps
801070d7:	e9 34 f7 ff ff       	jmp    80106810 <alltraps>

801070dc <vector46>:
.globl vector46
vector46:
  pushl $0
801070dc:	6a 00                	push   $0x0
  pushl $46
801070de:	6a 2e                	push   $0x2e
  jmp alltraps
801070e0:	e9 2b f7 ff ff       	jmp    80106810 <alltraps>

801070e5 <vector47>:
.globl vector47
vector47:
  pushl $0
801070e5:	6a 00                	push   $0x0
  pushl $47
801070e7:	6a 2f                	push   $0x2f
  jmp alltraps
801070e9:	e9 22 f7 ff ff       	jmp    80106810 <alltraps>

801070ee <vector48>:
.globl vector48
vector48:
  pushl $0
801070ee:	6a 00                	push   $0x0
  pushl $48
801070f0:	6a 30                	push   $0x30
  jmp alltraps
801070f2:	e9 19 f7 ff ff       	jmp    80106810 <alltraps>

801070f7 <vector49>:
.globl vector49
vector49:
  pushl $0
801070f7:	6a 00                	push   $0x0
  pushl $49
801070f9:	6a 31                	push   $0x31
  jmp alltraps
801070fb:	e9 10 f7 ff ff       	jmp    80106810 <alltraps>

80107100 <vector50>:
.globl vector50
vector50:
  pushl $0
80107100:	6a 00                	push   $0x0
  pushl $50
80107102:	6a 32                	push   $0x32
  jmp alltraps
80107104:	e9 07 f7 ff ff       	jmp    80106810 <alltraps>

80107109 <vector51>:
.globl vector51
vector51:
  pushl $0
80107109:	6a 00                	push   $0x0
  pushl $51
8010710b:	6a 33                	push   $0x33
  jmp alltraps
8010710d:	e9 fe f6 ff ff       	jmp    80106810 <alltraps>

80107112 <vector52>:
.globl vector52
vector52:
  pushl $0
80107112:	6a 00                	push   $0x0
  pushl $52
80107114:	6a 34                	push   $0x34
  jmp alltraps
80107116:	e9 f5 f6 ff ff       	jmp    80106810 <alltraps>

8010711b <vector53>:
.globl vector53
vector53:
  pushl $0
8010711b:	6a 00                	push   $0x0
  pushl $53
8010711d:	6a 35                	push   $0x35
  jmp alltraps
8010711f:	e9 ec f6 ff ff       	jmp    80106810 <alltraps>

80107124 <vector54>:
.globl vector54
vector54:
  pushl $0
80107124:	6a 00                	push   $0x0
  pushl $54
80107126:	6a 36                	push   $0x36
  jmp alltraps
80107128:	e9 e3 f6 ff ff       	jmp    80106810 <alltraps>

8010712d <vector55>:
.globl vector55
vector55:
  pushl $0
8010712d:	6a 00                	push   $0x0
  pushl $55
8010712f:	6a 37                	push   $0x37
  jmp alltraps
80107131:	e9 da f6 ff ff       	jmp    80106810 <alltraps>

80107136 <vector56>:
.globl vector56
vector56:
  pushl $0
80107136:	6a 00                	push   $0x0
  pushl $56
80107138:	6a 38                	push   $0x38
  jmp alltraps
8010713a:	e9 d1 f6 ff ff       	jmp    80106810 <alltraps>

8010713f <vector57>:
.globl vector57
vector57:
  pushl $0
8010713f:	6a 00                	push   $0x0
  pushl $57
80107141:	6a 39                	push   $0x39
  jmp alltraps
80107143:	e9 c8 f6 ff ff       	jmp    80106810 <alltraps>

80107148 <vector58>:
.globl vector58
vector58:
  pushl $0
80107148:	6a 00                	push   $0x0
  pushl $58
8010714a:	6a 3a                	push   $0x3a
  jmp alltraps
8010714c:	e9 bf f6 ff ff       	jmp    80106810 <alltraps>

80107151 <vector59>:
.globl vector59
vector59:
  pushl $0
80107151:	6a 00                	push   $0x0
  pushl $59
80107153:	6a 3b                	push   $0x3b
  jmp alltraps
80107155:	e9 b6 f6 ff ff       	jmp    80106810 <alltraps>

8010715a <vector60>:
.globl vector60
vector60:
  pushl $0
8010715a:	6a 00                	push   $0x0
  pushl $60
8010715c:	6a 3c                	push   $0x3c
  jmp alltraps
8010715e:	e9 ad f6 ff ff       	jmp    80106810 <alltraps>

80107163 <vector61>:
.globl vector61
vector61:
  pushl $0
80107163:	6a 00                	push   $0x0
  pushl $61
80107165:	6a 3d                	push   $0x3d
  jmp alltraps
80107167:	e9 a4 f6 ff ff       	jmp    80106810 <alltraps>

8010716c <vector62>:
.globl vector62
vector62:
  pushl $0
8010716c:	6a 00                	push   $0x0
  pushl $62
8010716e:	6a 3e                	push   $0x3e
  jmp alltraps
80107170:	e9 9b f6 ff ff       	jmp    80106810 <alltraps>

80107175 <vector63>:
.globl vector63
vector63:
  pushl $0
80107175:	6a 00                	push   $0x0
  pushl $63
80107177:	6a 3f                	push   $0x3f
  jmp alltraps
80107179:	e9 92 f6 ff ff       	jmp    80106810 <alltraps>

8010717e <vector64>:
.globl vector64
vector64:
  pushl $0
8010717e:	6a 00                	push   $0x0
  pushl $64
80107180:	6a 40                	push   $0x40
  jmp alltraps
80107182:	e9 89 f6 ff ff       	jmp    80106810 <alltraps>

80107187 <vector65>:
.globl vector65
vector65:
  pushl $0
80107187:	6a 00                	push   $0x0
  pushl $65
80107189:	6a 41                	push   $0x41
  jmp alltraps
8010718b:	e9 80 f6 ff ff       	jmp    80106810 <alltraps>

80107190 <vector66>:
.globl vector66
vector66:
  pushl $0
80107190:	6a 00                	push   $0x0
  pushl $66
80107192:	6a 42                	push   $0x42
  jmp alltraps
80107194:	e9 77 f6 ff ff       	jmp    80106810 <alltraps>

80107199 <vector67>:
.globl vector67
vector67:
  pushl $0
80107199:	6a 00                	push   $0x0
  pushl $67
8010719b:	6a 43                	push   $0x43
  jmp alltraps
8010719d:	e9 6e f6 ff ff       	jmp    80106810 <alltraps>

801071a2 <vector68>:
.globl vector68
vector68:
  pushl $0
801071a2:	6a 00                	push   $0x0
  pushl $68
801071a4:	6a 44                	push   $0x44
  jmp alltraps
801071a6:	e9 65 f6 ff ff       	jmp    80106810 <alltraps>

801071ab <vector69>:
.globl vector69
vector69:
  pushl $0
801071ab:	6a 00                	push   $0x0
  pushl $69
801071ad:	6a 45                	push   $0x45
  jmp alltraps
801071af:	e9 5c f6 ff ff       	jmp    80106810 <alltraps>

801071b4 <vector70>:
.globl vector70
vector70:
  pushl $0
801071b4:	6a 00                	push   $0x0
  pushl $70
801071b6:	6a 46                	push   $0x46
  jmp alltraps
801071b8:	e9 53 f6 ff ff       	jmp    80106810 <alltraps>

801071bd <vector71>:
.globl vector71
vector71:
  pushl $0
801071bd:	6a 00                	push   $0x0
  pushl $71
801071bf:	6a 47                	push   $0x47
  jmp alltraps
801071c1:	e9 4a f6 ff ff       	jmp    80106810 <alltraps>

801071c6 <vector72>:
.globl vector72
vector72:
  pushl $0
801071c6:	6a 00                	push   $0x0
  pushl $72
801071c8:	6a 48                	push   $0x48
  jmp alltraps
801071ca:	e9 41 f6 ff ff       	jmp    80106810 <alltraps>

801071cf <vector73>:
.globl vector73
vector73:
  pushl $0
801071cf:	6a 00                	push   $0x0
  pushl $73
801071d1:	6a 49                	push   $0x49
  jmp alltraps
801071d3:	e9 38 f6 ff ff       	jmp    80106810 <alltraps>

801071d8 <vector74>:
.globl vector74
vector74:
  pushl $0
801071d8:	6a 00                	push   $0x0
  pushl $74
801071da:	6a 4a                	push   $0x4a
  jmp alltraps
801071dc:	e9 2f f6 ff ff       	jmp    80106810 <alltraps>

801071e1 <vector75>:
.globl vector75
vector75:
  pushl $0
801071e1:	6a 00                	push   $0x0
  pushl $75
801071e3:	6a 4b                	push   $0x4b
  jmp alltraps
801071e5:	e9 26 f6 ff ff       	jmp    80106810 <alltraps>

801071ea <vector76>:
.globl vector76
vector76:
  pushl $0
801071ea:	6a 00                	push   $0x0
  pushl $76
801071ec:	6a 4c                	push   $0x4c
  jmp alltraps
801071ee:	e9 1d f6 ff ff       	jmp    80106810 <alltraps>

801071f3 <vector77>:
.globl vector77
vector77:
  pushl $0
801071f3:	6a 00                	push   $0x0
  pushl $77
801071f5:	6a 4d                	push   $0x4d
  jmp alltraps
801071f7:	e9 14 f6 ff ff       	jmp    80106810 <alltraps>

801071fc <vector78>:
.globl vector78
vector78:
  pushl $0
801071fc:	6a 00                	push   $0x0
  pushl $78
801071fe:	6a 4e                	push   $0x4e
  jmp alltraps
80107200:	e9 0b f6 ff ff       	jmp    80106810 <alltraps>

80107205 <vector79>:
.globl vector79
vector79:
  pushl $0
80107205:	6a 00                	push   $0x0
  pushl $79
80107207:	6a 4f                	push   $0x4f
  jmp alltraps
80107209:	e9 02 f6 ff ff       	jmp    80106810 <alltraps>

8010720e <vector80>:
.globl vector80
vector80:
  pushl $0
8010720e:	6a 00                	push   $0x0
  pushl $80
80107210:	6a 50                	push   $0x50
  jmp alltraps
80107212:	e9 f9 f5 ff ff       	jmp    80106810 <alltraps>

80107217 <vector81>:
.globl vector81
vector81:
  pushl $0
80107217:	6a 00                	push   $0x0
  pushl $81
80107219:	6a 51                	push   $0x51
  jmp alltraps
8010721b:	e9 f0 f5 ff ff       	jmp    80106810 <alltraps>

80107220 <vector82>:
.globl vector82
vector82:
  pushl $0
80107220:	6a 00                	push   $0x0
  pushl $82
80107222:	6a 52                	push   $0x52
  jmp alltraps
80107224:	e9 e7 f5 ff ff       	jmp    80106810 <alltraps>

80107229 <vector83>:
.globl vector83
vector83:
  pushl $0
80107229:	6a 00                	push   $0x0
  pushl $83
8010722b:	6a 53                	push   $0x53
  jmp alltraps
8010722d:	e9 de f5 ff ff       	jmp    80106810 <alltraps>

80107232 <vector84>:
.globl vector84
vector84:
  pushl $0
80107232:	6a 00                	push   $0x0
  pushl $84
80107234:	6a 54                	push   $0x54
  jmp alltraps
80107236:	e9 d5 f5 ff ff       	jmp    80106810 <alltraps>

8010723b <vector85>:
.globl vector85
vector85:
  pushl $0
8010723b:	6a 00                	push   $0x0
  pushl $85
8010723d:	6a 55                	push   $0x55
  jmp alltraps
8010723f:	e9 cc f5 ff ff       	jmp    80106810 <alltraps>

80107244 <vector86>:
.globl vector86
vector86:
  pushl $0
80107244:	6a 00                	push   $0x0
  pushl $86
80107246:	6a 56                	push   $0x56
  jmp alltraps
80107248:	e9 c3 f5 ff ff       	jmp    80106810 <alltraps>

8010724d <vector87>:
.globl vector87
vector87:
  pushl $0
8010724d:	6a 00                	push   $0x0
  pushl $87
8010724f:	6a 57                	push   $0x57
  jmp alltraps
80107251:	e9 ba f5 ff ff       	jmp    80106810 <alltraps>

80107256 <vector88>:
.globl vector88
vector88:
  pushl $0
80107256:	6a 00                	push   $0x0
  pushl $88
80107258:	6a 58                	push   $0x58
  jmp alltraps
8010725a:	e9 b1 f5 ff ff       	jmp    80106810 <alltraps>

8010725f <vector89>:
.globl vector89
vector89:
  pushl $0
8010725f:	6a 00                	push   $0x0
  pushl $89
80107261:	6a 59                	push   $0x59
  jmp alltraps
80107263:	e9 a8 f5 ff ff       	jmp    80106810 <alltraps>

80107268 <vector90>:
.globl vector90
vector90:
  pushl $0
80107268:	6a 00                	push   $0x0
  pushl $90
8010726a:	6a 5a                	push   $0x5a
  jmp alltraps
8010726c:	e9 9f f5 ff ff       	jmp    80106810 <alltraps>

80107271 <vector91>:
.globl vector91
vector91:
  pushl $0
80107271:	6a 00                	push   $0x0
  pushl $91
80107273:	6a 5b                	push   $0x5b
  jmp alltraps
80107275:	e9 96 f5 ff ff       	jmp    80106810 <alltraps>

8010727a <vector92>:
.globl vector92
vector92:
  pushl $0
8010727a:	6a 00                	push   $0x0
  pushl $92
8010727c:	6a 5c                	push   $0x5c
  jmp alltraps
8010727e:	e9 8d f5 ff ff       	jmp    80106810 <alltraps>

80107283 <vector93>:
.globl vector93
vector93:
  pushl $0
80107283:	6a 00                	push   $0x0
  pushl $93
80107285:	6a 5d                	push   $0x5d
  jmp alltraps
80107287:	e9 84 f5 ff ff       	jmp    80106810 <alltraps>

8010728c <vector94>:
.globl vector94
vector94:
  pushl $0
8010728c:	6a 00                	push   $0x0
  pushl $94
8010728e:	6a 5e                	push   $0x5e
  jmp alltraps
80107290:	e9 7b f5 ff ff       	jmp    80106810 <alltraps>

80107295 <vector95>:
.globl vector95
vector95:
  pushl $0
80107295:	6a 00                	push   $0x0
  pushl $95
80107297:	6a 5f                	push   $0x5f
  jmp alltraps
80107299:	e9 72 f5 ff ff       	jmp    80106810 <alltraps>

8010729e <vector96>:
.globl vector96
vector96:
  pushl $0
8010729e:	6a 00                	push   $0x0
  pushl $96
801072a0:	6a 60                	push   $0x60
  jmp alltraps
801072a2:	e9 69 f5 ff ff       	jmp    80106810 <alltraps>

801072a7 <vector97>:
.globl vector97
vector97:
  pushl $0
801072a7:	6a 00                	push   $0x0
  pushl $97
801072a9:	6a 61                	push   $0x61
  jmp alltraps
801072ab:	e9 60 f5 ff ff       	jmp    80106810 <alltraps>

801072b0 <vector98>:
.globl vector98
vector98:
  pushl $0
801072b0:	6a 00                	push   $0x0
  pushl $98
801072b2:	6a 62                	push   $0x62
  jmp alltraps
801072b4:	e9 57 f5 ff ff       	jmp    80106810 <alltraps>

801072b9 <vector99>:
.globl vector99
vector99:
  pushl $0
801072b9:	6a 00                	push   $0x0
  pushl $99
801072bb:	6a 63                	push   $0x63
  jmp alltraps
801072bd:	e9 4e f5 ff ff       	jmp    80106810 <alltraps>

801072c2 <vector100>:
.globl vector100
vector100:
  pushl $0
801072c2:	6a 00                	push   $0x0
  pushl $100
801072c4:	6a 64                	push   $0x64
  jmp alltraps
801072c6:	e9 45 f5 ff ff       	jmp    80106810 <alltraps>

801072cb <vector101>:
.globl vector101
vector101:
  pushl $0
801072cb:	6a 00                	push   $0x0
  pushl $101
801072cd:	6a 65                	push   $0x65
  jmp alltraps
801072cf:	e9 3c f5 ff ff       	jmp    80106810 <alltraps>

801072d4 <vector102>:
.globl vector102
vector102:
  pushl $0
801072d4:	6a 00                	push   $0x0
  pushl $102
801072d6:	6a 66                	push   $0x66
  jmp alltraps
801072d8:	e9 33 f5 ff ff       	jmp    80106810 <alltraps>

801072dd <vector103>:
.globl vector103
vector103:
  pushl $0
801072dd:	6a 00                	push   $0x0
  pushl $103
801072df:	6a 67                	push   $0x67
  jmp alltraps
801072e1:	e9 2a f5 ff ff       	jmp    80106810 <alltraps>

801072e6 <vector104>:
.globl vector104
vector104:
  pushl $0
801072e6:	6a 00                	push   $0x0
  pushl $104
801072e8:	6a 68                	push   $0x68
  jmp alltraps
801072ea:	e9 21 f5 ff ff       	jmp    80106810 <alltraps>

801072ef <vector105>:
.globl vector105
vector105:
  pushl $0
801072ef:	6a 00                	push   $0x0
  pushl $105
801072f1:	6a 69                	push   $0x69
  jmp alltraps
801072f3:	e9 18 f5 ff ff       	jmp    80106810 <alltraps>

801072f8 <vector106>:
.globl vector106
vector106:
  pushl $0
801072f8:	6a 00                	push   $0x0
  pushl $106
801072fa:	6a 6a                	push   $0x6a
  jmp alltraps
801072fc:	e9 0f f5 ff ff       	jmp    80106810 <alltraps>

80107301 <vector107>:
.globl vector107
vector107:
  pushl $0
80107301:	6a 00                	push   $0x0
  pushl $107
80107303:	6a 6b                	push   $0x6b
  jmp alltraps
80107305:	e9 06 f5 ff ff       	jmp    80106810 <alltraps>

8010730a <vector108>:
.globl vector108
vector108:
  pushl $0
8010730a:	6a 00                	push   $0x0
  pushl $108
8010730c:	6a 6c                	push   $0x6c
  jmp alltraps
8010730e:	e9 fd f4 ff ff       	jmp    80106810 <alltraps>

80107313 <vector109>:
.globl vector109
vector109:
  pushl $0
80107313:	6a 00                	push   $0x0
  pushl $109
80107315:	6a 6d                	push   $0x6d
  jmp alltraps
80107317:	e9 f4 f4 ff ff       	jmp    80106810 <alltraps>

8010731c <vector110>:
.globl vector110
vector110:
  pushl $0
8010731c:	6a 00                	push   $0x0
  pushl $110
8010731e:	6a 6e                	push   $0x6e
  jmp alltraps
80107320:	e9 eb f4 ff ff       	jmp    80106810 <alltraps>

80107325 <vector111>:
.globl vector111
vector111:
  pushl $0
80107325:	6a 00                	push   $0x0
  pushl $111
80107327:	6a 6f                	push   $0x6f
  jmp alltraps
80107329:	e9 e2 f4 ff ff       	jmp    80106810 <alltraps>

8010732e <vector112>:
.globl vector112
vector112:
  pushl $0
8010732e:	6a 00                	push   $0x0
  pushl $112
80107330:	6a 70                	push   $0x70
  jmp alltraps
80107332:	e9 d9 f4 ff ff       	jmp    80106810 <alltraps>

80107337 <vector113>:
.globl vector113
vector113:
  pushl $0
80107337:	6a 00                	push   $0x0
  pushl $113
80107339:	6a 71                	push   $0x71
  jmp alltraps
8010733b:	e9 d0 f4 ff ff       	jmp    80106810 <alltraps>

80107340 <vector114>:
.globl vector114
vector114:
  pushl $0
80107340:	6a 00                	push   $0x0
  pushl $114
80107342:	6a 72                	push   $0x72
  jmp alltraps
80107344:	e9 c7 f4 ff ff       	jmp    80106810 <alltraps>

80107349 <vector115>:
.globl vector115
vector115:
  pushl $0
80107349:	6a 00                	push   $0x0
  pushl $115
8010734b:	6a 73                	push   $0x73
  jmp alltraps
8010734d:	e9 be f4 ff ff       	jmp    80106810 <alltraps>

80107352 <vector116>:
.globl vector116
vector116:
  pushl $0
80107352:	6a 00                	push   $0x0
  pushl $116
80107354:	6a 74                	push   $0x74
  jmp alltraps
80107356:	e9 b5 f4 ff ff       	jmp    80106810 <alltraps>

8010735b <vector117>:
.globl vector117
vector117:
  pushl $0
8010735b:	6a 00                	push   $0x0
  pushl $117
8010735d:	6a 75                	push   $0x75
  jmp alltraps
8010735f:	e9 ac f4 ff ff       	jmp    80106810 <alltraps>

80107364 <vector118>:
.globl vector118
vector118:
  pushl $0
80107364:	6a 00                	push   $0x0
  pushl $118
80107366:	6a 76                	push   $0x76
  jmp alltraps
80107368:	e9 a3 f4 ff ff       	jmp    80106810 <alltraps>

8010736d <vector119>:
.globl vector119
vector119:
  pushl $0
8010736d:	6a 00                	push   $0x0
  pushl $119
8010736f:	6a 77                	push   $0x77
  jmp alltraps
80107371:	e9 9a f4 ff ff       	jmp    80106810 <alltraps>

80107376 <vector120>:
.globl vector120
vector120:
  pushl $0
80107376:	6a 00                	push   $0x0
  pushl $120
80107378:	6a 78                	push   $0x78
  jmp alltraps
8010737a:	e9 91 f4 ff ff       	jmp    80106810 <alltraps>

8010737f <vector121>:
.globl vector121
vector121:
  pushl $0
8010737f:	6a 00                	push   $0x0
  pushl $121
80107381:	6a 79                	push   $0x79
  jmp alltraps
80107383:	e9 88 f4 ff ff       	jmp    80106810 <alltraps>

80107388 <vector122>:
.globl vector122
vector122:
  pushl $0
80107388:	6a 00                	push   $0x0
  pushl $122
8010738a:	6a 7a                	push   $0x7a
  jmp alltraps
8010738c:	e9 7f f4 ff ff       	jmp    80106810 <alltraps>

80107391 <vector123>:
.globl vector123
vector123:
  pushl $0
80107391:	6a 00                	push   $0x0
  pushl $123
80107393:	6a 7b                	push   $0x7b
  jmp alltraps
80107395:	e9 76 f4 ff ff       	jmp    80106810 <alltraps>

8010739a <vector124>:
.globl vector124
vector124:
  pushl $0
8010739a:	6a 00                	push   $0x0
  pushl $124
8010739c:	6a 7c                	push   $0x7c
  jmp alltraps
8010739e:	e9 6d f4 ff ff       	jmp    80106810 <alltraps>

801073a3 <vector125>:
.globl vector125
vector125:
  pushl $0
801073a3:	6a 00                	push   $0x0
  pushl $125
801073a5:	6a 7d                	push   $0x7d
  jmp alltraps
801073a7:	e9 64 f4 ff ff       	jmp    80106810 <alltraps>

801073ac <vector126>:
.globl vector126
vector126:
  pushl $0
801073ac:	6a 00                	push   $0x0
  pushl $126
801073ae:	6a 7e                	push   $0x7e
  jmp alltraps
801073b0:	e9 5b f4 ff ff       	jmp    80106810 <alltraps>

801073b5 <vector127>:
.globl vector127
vector127:
  pushl $0
801073b5:	6a 00                	push   $0x0
  pushl $127
801073b7:	6a 7f                	push   $0x7f
  jmp alltraps
801073b9:	e9 52 f4 ff ff       	jmp    80106810 <alltraps>

801073be <vector128>:
.globl vector128
vector128:
  pushl $0
801073be:	6a 00                	push   $0x0
  pushl $128
801073c0:	68 80 00 00 00       	push   $0x80
  jmp alltraps
801073c5:	e9 46 f4 ff ff       	jmp    80106810 <alltraps>

801073ca <vector129>:
.globl vector129
vector129:
  pushl $0
801073ca:	6a 00                	push   $0x0
  pushl $129
801073cc:	68 81 00 00 00       	push   $0x81
  jmp alltraps
801073d1:	e9 3a f4 ff ff       	jmp    80106810 <alltraps>

801073d6 <vector130>:
.globl vector130
vector130:
  pushl $0
801073d6:	6a 00                	push   $0x0
  pushl $130
801073d8:	68 82 00 00 00       	push   $0x82
  jmp alltraps
801073dd:	e9 2e f4 ff ff       	jmp    80106810 <alltraps>

801073e2 <vector131>:
.globl vector131
vector131:
  pushl $0
801073e2:	6a 00                	push   $0x0
  pushl $131
801073e4:	68 83 00 00 00       	push   $0x83
  jmp alltraps
801073e9:	e9 22 f4 ff ff       	jmp    80106810 <alltraps>

801073ee <vector132>:
.globl vector132
vector132:
  pushl $0
801073ee:	6a 00                	push   $0x0
  pushl $132
801073f0:	68 84 00 00 00       	push   $0x84
  jmp alltraps
801073f5:	e9 16 f4 ff ff       	jmp    80106810 <alltraps>

801073fa <vector133>:
.globl vector133
vector133:
  pushl $0
801073fa:	6a 00                	push   $0x0
  pushl $133
801073fc:	68 85 00 00 00       	push   $0x85
  jmp alltraps
80107401:	e9 0a f4 ff ff       	jmp    80106810 <alltraps>

80107406 <vector134>:
.globl vector134
vector134:
  pushl $0
80107406:	6a 00                	push   $0x0
  pushl $134
80107408:	68 86 00 00 00       	push   $0x86
  jmp alltraps
8010740d:	e9 fe f3 ff ff       	jmp    80106810 <alltraps>

80107412 <vector135>:
.globl vector135
vector135:
  pushl $0
80107412:	6a 00                	push   $0x0
  pushl $135
80107414:	68 87 00 00 00       	push   $0x87
  jmp alltraps
80107419:	e9 f2 f3 ff ff       	jmp    80106810 <alltraps>

8010741e <vector136>:
.globl vector136
vector136:
  pushl $0
8010741e:	6a 00                	push   $0x0
  pushl $136
80107420:	68 88 00 00 00       	push   $0x88
  jmp alltraps
80107425:	e9 e6 f3 ff ff       	jmp    80106810 <alltraps>

8010742a <vector137>:
.globl vector137
vector137:
  pushl $0
8010742a:	6a 00                	push   $0x0
  pushl $137
8010742c:	68 89 00 00 00       	push   $0x89
  jmp alltraps
80107431:	e9 da f3 ff ff       	jmp    80106810 <alltraps>

80107436 <vector138>:
.globl vector138
vector138:
  pushl $0
80107436:	6a 00                	push   $0x0
  pushl $138
80107438:	68 8a 00 00 00       	push   $0x8a
  jmp alltraps
8010743d:	e9 ce f3 ff ff       	jmp    80106810 <alltraps>

80107442 <vector139>:
.globl vector139
vector139:
  pushl $0
80107442:	6a 00                	push   $0x0
  pushl $139
80107444:	68 8b 00 00 00       	push   $0x8b
  jmp alltraps
80107449:	e9 c2 f3 ff ff       	jmp    80106810 <alltraps>

8010744e <vector140>:
.globl vector140
vector140:
  pushl $0
8010744e:	6a 00                	push   $0x0
  pushl $140
80107450:	68 8c 00 00 00       	push   $0x8c
  jmp alltraps
80107455:	e9 b6 f3 ff ff       	jmp    80106810 <alltraps>

8010745a <vector141>:
.globl vector141
vector141:
  pushl $0
8010745a:	6a 00                	push   $0x0
  pushl $141
8010745c:	68 8d 00 00 00       	push   $0x8d
  jmp alltraps
80107461:	e9 aa f3 ff ff       	jmp    80106810 <alltraps>

80107466 <vector142>:
.globl vector142
vector142:
  pushl $0
80107466:	6a 00                	push   $0x0
  pushl $142
80107468:	68 8e 00 00 00       	push   $0x8e
  jmp alltraps
8010746d:	e9 9e f3 ff ff       	jmp    80106810 <alltraps>

80107472 <vector143>:
.globl vector143
vector143:
  pushl $0
80107472:	6a 00                	push   $0x0
  pushl $143
80107474:	68 8f 00 00 00       	push   $0x8f
  jmp alltraps
80107479:	e9 92 f3 ff ff       	jmp    80106810 <alltraps>

8010747e <vector144>:
.globl vector144
vector144:
  pushl $0
8010747e:	6a 00                	push   $0x0
  pushl $144
80107480:	68 90 00 00 00       	push   $0x90
  jmp alltraps
80107485:	e9 86 f3 ff ff       	jmp    80106810 <alltraps>

8010748a <vector145>:
.globl vector145
vector145:
  pushl $0
8010748a:	6a 00                	push   $0x0
  pushl $145
8010748c:	68 91 00 00 00       	push   $0x91
  jmp alltraps
80107491:	e9 7a f3 ff ff       	jmp    80106810 <alltraps>

80107496 <vector146>:
.globl vector146
vector146:
  pushl $0
80107496:	6a 00                	push   $0x0
  pushl $146
80107498:	68 92 00 00 00       	push   $0x92
  jmp alltraps
8010749d:	e9 6e f3 ff ff       	jmp    80106810 <alltraps>

801074a2 <vector147>:
.globl vector147
vector147:
  pushl $0
801074a2:	6a 00                	push   $0x0
  pushl $147
801074a4:	68 93 00 00 00       	push   $0x93
  jmp alltraps
801074a9:	e9 62 f3 ff ff       	jmp    80106810 <alltraps>

801074ae <vector148>:
.globl vector148
vector148:
  pushl $0
801074ae:	6a 00                	push   $0x0
  pushl $148
801074b0:	68 94 00 00 00       	push   $0x94
  jmp alltraps
801074b5:	e9 56 f3 ff ff       	jmp    80106810 <alltraps>

801074ba <vector149>:
.globl vector149
vector149:
  pushl $0
801074ba:	6a 00                	push   $0x0
  pushl $149
801074bc:	68 95 00 00 00       	push   $0x95
  jmp alltraps
801074c1:	e9 4a f3 ff ff       	jmp    80106810 <alltraps>

801074c6 <vector150>:
.globl vector150
vector150:
  pushl $0
801074c6:	6a 00                	push   $0x0
  pushl $150
801074c8:	68 96 00 00 00       	push   $0x96
  jmp alltraps
801074cd:	e9 3e f3 ff ff       	jmp    80106810 <alltraps>

801074d2 <vector151>:
.globl vector151
vector151:
  pushl $0
801074d2:	6a 00                	push   $0x0
  pushl $151
801074d4:	68 97 00 00 00       	push   $0x97
  jmp alltraps
801074d9:	e9 32 f3 ff ff       	jmp    80106810 <alltraps>

801074de <vector152>:
.globl vector152
vector152:
  pushl $0
801074de:	6a 00                	push   $0x0
  pushl $152
801074e0:	68 98 00 00 00       	push   $0x98
  jmp alltraps
801074e5:	e9 26 f3 ff ff       	jmp    80106810 <alltraps>

801074ea <vector153>:
.globl vector153
vector153:
  pushl $0
801074ea:	6a 00                	push   $0x0
  pushl $153
801074ec:	68 99 00 00 00       	push   $0x99
  jmp alltraps
801074f1:	e9 1a f3 ff ff       	jmp    80106810 <alltraps>

801074f6 <vector154>:
.globl vector154
vector154:
  pushl $0
801074f6:	6a 00                	push   $0x0
  pushl $154
801074f8:	68 9a 00 00 00       	push   $0x9a
  jmp alltraps
801074fd:	e9 0e f3 ff ff       	jmp    80106810 <alltraps>

80107502 <vector155>:
.globl vector155
vector155:
  pushl $0
80107502:	6a 00                	push   $0x0
  pushl $155
80107504:	68 9b 00 00 00       	push   $0x9b
  jmp alltraps
80107509:	e9 02 f3 ff ff       	jmp    80106810 <alltraps>

8010750e <vector156>:
.globl vector156
vector156:
  pushl $0
8010750e:	6a 00                	push   $0x0
  pushl $156
80107510:	68 9c 00 00 00       	push   $0x9c
  jmp alltraps
80107515:	e9 f6 f2 ff ff       	jmp    80106810 <alltraps>

8010751a <vector157>:
.globl vector157
vector157:
  pushl $0
8010751a:	6a 00                	push   $0x0
  pushl $157
8010751c:	68 9d 00 00 00       	push   $0x9d
  jmp alltraps
80107521:	e9 ea f2 ff ff       	jmp    80106810 <alltraps>

80107526 <vector158>:
.globl vector158
vector158:
  pushl $0
80107526:	6a 00                	push   $0x0
  pushl $158
80107528:	68 9e 00 00 00       	push   $0x9e
  jmp alltraps
8010752d:	e9 de f2 ff ff       	jmp    80106810 <alltraps>

80107532 <vector159>:
.globl vector159
vector159:
  pushl $0
80107532:	6a 00                	push   $0x0
  pushl $159
80107534:	68 9f 00 00 00       	push   $0x9f
  jmp alltraps
80107539:	e9 d2 f2 ff ff       	jmp    80106810 <alltraps>

8010753e <vector160>:
.globl vector160
vector160:
  pushl $0
8010753e:	6a 00                	push   $0x0
  pushl $160
80107540:	68 a0 00 00 00       	push   $0xa0
  jmp alltraps
80107545:	e9 c6 f2 ff ff       	jmp    80106810 <alltraps>

8010754a <vector161>:
.globl vector161
vector161:
  pushl $0
8010754a:	6a 00                	push   $0x0
  pushl $161
8010754c:	68 a1 00 00 00       	push   $0xa1
  jmp alltraps
80107551:	e9 ba f2 ff ff       	jmp    80106810 <alltraps>

80107556 <vector162>:
.globl vector162
vector162:
  pushl $0
80107556:	6a 00                	push   $0x0
  pushl $162
80107558:	68 a2 00 00 00       	push   $0xa2
  jmp alltraps
8010755d:	e9 ae f2 ff ff       	jmp    80106810 <alltraps>

80107562 <vector163>:
.globl vector163
vector163:
  pushl $0
80107562:	6a 00                	push   $0x0
  pushl $163
80107564:	68 a3 00 00 00       	push   $0xa3
  jmp alltraps
80107569:	e9 a2 f2 ff ff       	jmp    80106810 <alltraps>

8010756e <vector164>:
.globl vector164
vector164:
  pushl $0
8010756e:	6a 00                	push   $0x0
  pushl $164
80107570:	68 a4 00 00 00       	push   $0xa4
  jmp alltraps
80107575:	e9 96 f2 ff ff       	jmp    80106810 <alltraps>

8010757a <vector165>:
.globl vector165
vector165:
  pushl $0
8010757a:	6a 00                	push   $0x0
  pushl $165
8010757c:	68 a5 00 00 00       	push   $0xa5
  jmp alltraps
80107581:	e9 8a f2 ff ff       	jmp    80106810 <alltraps>

80107586 <vector166>:
.globl vector166
vector166:
  pushl $0
80107586:	6a 00                	push   $0x0
  pushl $166
80107588:	68 a6 00 00 00       	push   $0xa6
  jmp alltraps
8010758d:	e9 7e f2 ff ff       	jmp    80106810 <alltraps>

80107592 <vector167>:
.globl vector167
vector167:
  pushl $0
80107592:	6a 00                	push   $0x0
  pushl $167
80107594:	68 a7 00 00 00       	push   $0xa7
  jmp alltraps
80107599:	e9 72 f2 ff ff       	jmp    80106810 <alltraps>

8010759e <vector168>:
.globl vector168
vector168:
  pushl $0
8010759e:	6a 00                	push   $0x0
  pushl $168
801075a0:	68 a8 00 00 00       	push   $0xa8
  jmp alltraps
801075a5:	e9 66 f2 ff ff       	jmp    80106810 <alltraps>

801075aa <vector169>:
.globl vector169
vector169:
  pushl $0
801075aa:	6a 00                	push   $0x0
  pushl $169
801075ac:	68 a9 00 00 00       	push   $0xa9
  jmp alltraps
801075b1:	e9 5a f2 ff ff       	jmp    80106810 <alltraps>

801075b6 <vector170>:
.globl vector170
vector170:
  pushl $0
801075b6:	6a 00                	push   $0x0
  pushl $170
801075b8:	68 aa 00 00 00       	push   $0xaa
  jmp alltraps
801075bd:	e9 4e f2 ff ff       	jmp    80106810 <alltraps>

801075c2 <vector171>:
.globl vector171
vector171:
  pushl $0
801075c2:	6a 00                	push   $0x0
  pushl $171
801075c4:	68 ab 00 00 00       	push   $0xab
  jmp alltraps
801075c9:	e9 42 f2 ff ff       	jmp    80106810 <alltraps>

801075ce <vector172>:
.globl vector172
vector172:
  pushl $0
801075ce:	6a 00                	push   $0x0
  pushl $172
801075d0:	68 ac 00 00 00       	push   $0xac
  jmp alltraps
801075d5:	e9 36 f2 ff ff       	jmp    80106810 <alltraps>

801075da <vector173>:
.globl vector173
vector173:
  pushl $0
801075da:	6a 00                	push   $0x0
  pushl $173
801075dc:	68 ad 00 00 00       	push   $0xad
  jmp alltraps
801075e1:	e9 2a f2 ff ff       	jmp    80106810 <alltraps>

801075e6 <vector174>:
.globl vector174
vector174:
  pushl $0
801075e6:	6a 00                	push   $0x0
  pushl $174
801075e8:	68 ae 00 00 00       	push   $0xae
  jmp alltraps
801075ed:	e9 1e f2 ff ff       	jmp    80106810 <alltraps>

801075f2 <vector175>:
.globl vector175
vector175:
  pushl $0
801075f2:	6a 00                	push   $0x0
  pushl $175
801075f4:	68 af 00 00 00       	push   $0xaf
  jmp alltraps
801075f9:	e9 12 f2 ff ff       	jmp    80106810 <alltraps>

801075fe <vector176>:
.globl vector176
vector176:
  pushl $0
801075fe:	6a 00                	push   $0x0
  pushl $176
80107600:	68 b0 00 00 00       	push   $0xb0
  jmp alltraps
80107605:	e9 06 f2 ff ff       	jmp    80106810 <alltraps>

8010760a <vector177>:
.globl vector177
vector177:
  pushl $0
8010760a:	6a 00                	push   $0x0
  pushl $177
8010760c:	68 b1 00 00 00       	push   $0xb1
  jmp alltraps
80107611:	e9 fa f1 ff ff       	jmp    80106810 <alltraps>

80107616 <vector178>:
.globl vector178
vector178:
  pushl $0
80107616:	6a 00                	push   $0x0
  pushl $178
80107618:	68 b2 00 00 00       	push   $0xb2
  jmp alltraps
8010761d:	e9 ee f1 ff ff       	jmp    80106810 <alltraps>

80107622 <vector179>:
.globl vector179
vector179:
  pushl $0
80107622:	6a 00                	push   $0x0
  pushl $179
80107624:	68 b3 00 00 00       	push   $0xb3
  jmp alltraps
80107629:	e9 e2 f1 ff ff       	jmp    80106810 <alltraps>

8010762e <vector180>:
.globl vector180
vector180:
  pushl $0
8010762e:	6a 00                	push   $0x0
  pushl $180
80107630:	68 b4 00 00 00       	push   $0xb4
  jmp alltraps
80107635:	e9 d6 f1 ff ff       	jmp    80106810 <alltraps>

8010763a <vector181>:
.globl vector181
vector181:
  pushl $0
8010763a:	6a 00                	push   $0x0
  pushl $181
8010763c:	68 b5 00 00 00       	push   $0xb5
  jmp alltraps
80107641:	e9 ca f1 ff ff       	jmp    80106810 <alltraps>

80107646 <vector182>:
.globl vector182
vector182:
  pushl $0
80107646:	6a 00                	push   $0x0
  pushl $182
80107648:	68 b6 00 00 00       	push   $0xb6
  jmp alltraps
8010764d:	e9 be f1 ff ff       	jmp    80106810 <alltraps>

80107652 <vector183>:
.globl vector183
vector183:
  pushl $0
80107652:	6a 00                	push   $0x0
  pushl $183
80107654:	68 b7 00 00 00       	push   $0xb7
  jmp alltraps
80107659:	e9 b2 f1 ff ff       	jmp    80106810 <alltraps>

8010765e <vector184>:
.globl vector184
vector184:
  pushl $0
8010765e:	6a 00                	push   $0x0
  pushl $184
80107660:	68 b8 00 00 00       	push   $0xb8
  jmp alltraps
80107665:	e9 a6 f1 ff ff       	jmp    80106810 <alltraps>

8010766a <vector185>:
.globl vector185
vector185:
  pushl $0
8010766a:	6a 00                	push   $0x0
  pushl $185
8010766c:	68 b9 00 00 00       	push   $0xb9
  jmp alltraps
80107671:	e9 9a f1 ff ff       	jmp    80106810 <alltraps>

80107676 <vector186>:
.globl vector186
vector186:
  pushl $0
80107676:	6a 00                	push   $0x0
  pushl $186
80107678:	68 ba 00 00 00       	push   $0xba
  jmp alltraps
8010767d:	e9 8e f1 ff ff       	jmp    80106810 <alltraps>

80107682 <vector187>:
.globl vector187
vector187:
  pushl $0
80107682:	6a 00                	push   $0x0
  pushl $187
80107684:	68 bb 00 00 00       	push   $0xbb
  jmp alltraps
80107689:	e9 82 f1 ff ff       	jmp    80106810 <alltraps>

8010768e <vector188>:
.globl vector188
vector188:
  pushl $0
8010768e:	6a 00                	push   $0x0
  pushl $188
80107690:	68 bc 00 00 00       	push   $0xbc
  jmp alltraps
80107695:	e9 76 f1 ff ff       	jmp    80106810 <alltraps>

8010769a <vector189>:
.globl vector189
vector189:
  pushl $0
8010769a:	6a 00                	push   $0x0
  pushl $189
8010769c:	68 bd 00 00 00       	push   $0xbd
  jmp alltraps
801076a1:	e9 6a f1 ff ff       	jmp    80106810 <alltraps>

801076a6 <vector190>:
.globl vector190
vector190:
  pushl $0
801076a6:	6a 00                	push   $0x0
  pushl $190
801076a8:	68 be 00 00 00       	push   $0xbe
  jmp alltraps
801076ad:	e9 5e f1 ff ff       	jmp    80106810 <alltraps>

801076b2 <vector191>:
.globl vector191
vector191:
  pushl $0
801076b2:	6a 00                	push   $0x0
  pushl $191
801076b4:	68 bf 00 00 00       	push   $0xbf
  jmp alltraps
801076b9:	e9 52 f1 ff ff       	jmp    80106810 <alltraps>

801076be <vector192>:
.globl vector192
vector192:
  pushl $0
801076be:	6a 00                	push   $0x0
  pushl $192
801076c0:	68 c0 00 00 00       	push   $0xc0
  jmp alltraps
801076c5:	e9 46 f1 ff ff       	jmp    80106810 <alltraps>

801076ca <vector193>:
.globl vector193
vector193:
  pushl $0
801076ca:	6a 00                	push   $0x0
  pushl $193
801076cc:	68 c1 00 00 00       	push   $0xc1
  jmp alltraps
801076d1:	e9 3a f1 ff ff       	jmp    80106810 <alltraps>

801076d6 <vector194>:
.globl vector194
vector194:
  pushl $0
801076d6:	6a 00                	push   $0x0
  pushl $194
801076d8:	68 c2 00 00 00       	push   $0xc2
  jmp alltraps
801076dd:	e9 2e f1 ff ff       	jmp    80106810 <alltraps>

801076e2 <vector195>:
.globl vector195
vector195:
  pushl $0
801076e2:	6a 00                	push   $0x0
  pushl $195
801076e4:	68 c3 00 00 00       	push   $0xc3
  jmp alltraps
801076e9:	e9 22 f1 ff ff       	jmp    80106810 <alltraps>

801076ee <vector196>:
.globl vector196
vector196:
  pushl $0
801076ee:	6a 00                	push   $0x0
  pushl $196
801076f0:	68 c4 00 00 00       	push   $0xc4
  jmp alltraps
801076f5:	e9 16 f1 ff ff       	jmp    80106810 <alltraps>

801076fa <vector197>:
.globl vector197
vector197:
  pushl $0
801076fa:	6a 00                	push   $0x0
  pushl $197
801076fc:	68 c5 00 00 00       	push   $0xc5
  jmp alltraps
80107701:	e9 0a f1 ff ff       	jmp    80106810 <alltraps>

80107706 <vector198>:
.globl vector198
vector198:
  pushl $0
80107706:	6a 00                	push   $0x0
  pushl $198
80107708:	68 c6 00 00 00       	push   $0xc6
  jmp alltraps
8010770d:	e9 fe f0 ff ff       	jmp    80106810 <alltraps>

80107712 <vector199>:
.globl vector199
vector199:
  pushl $0
80107712:	6a 00                	push   $0x0
  pushl $199
80107714:	68 c7 00 00 00       	push   $0xc7
  jmp alltraps
80107719:	e9 f2 f0 ff ff       	jmp    80106810 <alltraps>

8010771e <vector200>:
.globl vector200
vector200:
  pushl $0
8010771e:	6a 00                	push   $0x0
  pushl $200
80107720:	68 c8 00 00 00       	push   $0xc8
  jmp alltraps
80107725:	e9 e6 f0 ff ff       	jmp    80106810 <alltraps>

8010772a <vector201>:
.globl vector201
vector201:
  pushl $0
8010772a:	6a 00                	push   $0x0
  pushl $201
8010772c:	68 c9 00 00 00       	push   $0xc9
  jmp alltraps
80107731:	e9 da f0 ff ff       	jmp    80106810 <alltraps>

80107736 <vector202>:
.globl vector202
vector202:
  pushl $0
80107736:	6a 00                	push   $0x0
  pushl $202
80107738:	68 ca 00 00 00       	push   $0xca
  jmp alltraps
8010773d:	e9 ce f0 ff ff       	jmp    80106810 <alltraps>

80107742 <vector203>:
.globl vector203
vector203:
  pushl $0
80107742:	6a 00                	push   $0x0
  pushl $203
80107744:	68 cb 00 00 00       	push   $0xcb
  jmp alltraps
80107749:	e9 c2 f0 ff ff       	jmp    80106810 <alltraps>

8010774e <vector204>:
.globl vector204
vector204:
  pushl $0
8010774e:	6a 00                	push   $0x0
  pushl $204
80107750:	68 cc 00 00 00       	push   $0xcc
  jmp alltraps
80107755:	e9 b6 f0 ff ff       	jmp    80106810 <alltraps>

8010775a <vector205>:
.globl vector205
vector205:
  pushl $0
8010775a:	6a 00                	push   $0x0
  pushl $205
8010775c:	68 cd 00 00 00       	push   $0xcd
  jmp alltraps
80107761:	e9 aa f0 ff ff       	jmp    80106810 <alltraps>

80107766 <vector206>:
.globl vector206
vector206:
  pushl $0
80107766:	6a 00                	push   $0x0
  pushl $206
80107768:	68 ce 00 00 00       	push   $0xce
  jmp alltraps
8010776d:	e9 9e f0 ff ff       	jmp    80106810 <alltraps>

80107772 <vector207>:
.globl vector207
vector207:
  pushl $0
80107772:	6a 00                	push   $0x0
  pushl $207
80107774:	68 cf 00 00 00       	push   $0xcf
  jmp alltraps
80107779:	e9 92 f0 ff ff       	jmp    80106810 <alltraps>

8010777e <vector208>:
.globl vector208
vector208:
  pushl $0
8010777e:	6a 00                	push   $0x0
  pushl $208
80107780:	68 d0 00 00 00       	push   $0xd0
  jmp alltraps
80107785:	e9 86 f0 ff ff       	jmp    80106810 <alltraps>

8010778a <vector209>:
.globl vector209
vector209:
  pushl $0
8010778a:	6a 00                	push   $0x0
  pushl $209
8010778c:	68 d1 00 00 00       	push   $0xd1
  jmp alltraps
80107791:	e9 7a f0 ff ff       	jmp    80106810 <alltraps>

80107796 <vector210>:
.globl vector210
vector210:
  pushl $0
80107796:	6a 00                	push   $0x0
  pushl $210
80107798:	68 d2 00 00 00       	push   $0xd2
  jmp alltraps
8010779d:	e9 6e f0 ff ff       	jmp    80106810 <alltraps>

801077a2 <vector211>:
.globl vector211
vector211:
  pushl $0
801077a2:	6a 00                	push   $0x0
  pushl $211
801077a4:	68 d3 00 00 00       	push   $0xd3
  jmp alltraps
801077a9:	e9 62 f0 ff ff       	jmp    80106810 <alltraps>

801077ae <vector212>:
.globl vector212
vector212:
  pushl $0
801077ae:	6a 00                	push   $0x0
  pushl $212
801077b0:	68 d4 00 00 00       	push   $0xd4
  jmp alltraps
801077b5:	e9 56 f0 ff ff       	jmp    80106810 <alltraps>

801077ba <vector213>:
.globl vector213
vector213:
  pushl $0
801077ba:	6a 00                	push   $0x0
  pushl $213
801077bc:	68 d5 00 00 00       	push   $0xd5
  jmp alltraps
801077c1:	e9 4a f0 ff ff       	jmp    80106810 <alltraps>

801077c6 <vector214>:
.globl vector214
vector214:
  pushl $0
801077c6:	6a 00                	push   $0x0
  pushl $214
801077c8:	68 d6 00 00 00       	push   $0xd6
  jmp alltraps
801077cd:	e9 3e f0 ff ff       	jmp    80106810 <alltraps>

801077d2 <vector215>:
.globl vector215
vector215:
  pushl $0
801077d2:	6a 00                	push   $0x0
  pushl $215
801077d4:	68 d7 00 00 00       	push   $0xd7
  jmp alltraps
801077d9:	e9 32 f0 ff ff       	jmp    80106810 <alltraps>

801077de <vector216>:
.globl vector216
vector216:
  pushl $0
801077de:	6a 00                	push   $0x0
  pushl $216
801077e0:	68 d8 00 00 00       	push   $0xd8
  jmp alltraps
801077e5:	e9 26 f0 ff ff       	jmp    80106810 <alltraps>

801077ea <vector217>:
.globl vector217
vector217:
  pushl $0
801077ea:	6a 00                	push   $0x0
  pushl $217
801077ec:	68 d9 00 00 00       	push   $0xd9
  jmp alltraps
801077f1:	e9 1a f0 ff ff       	jmp    80106810 <alltraps>

801077f6 <vector218>:
.globl vector218
vector218:
  pushl $0
801077f6:	6a 00                	push   $0x0
  pushl $218
801077f8:	68 da 00 00 00       	push   $0xda
  jmp alltraps
801077fd:	e9 0e f0 ff ff       	jmp    80106810 <alltraps>

80107802 <vector219>:
.globl vector219
vector219:
  pushl $0
80107802:	6a 00                	push   $0x0
  pushl $219
80107804:	68 db 00 00 00       	push   $0xdb
  jmp alltraps
80107809:	e9 02 f0 ff ff       	jmp    80106810 <alltraps>

8010780e <vector220>:
.globl vector220
vector220:
  pushl $0
8010780e:	6a 00                	push   $0x0
  pushl $220
80107810:	68 dc 00 00 00       	push   $0xdc
  jmp alltraps
80107815:	e9 f6 ef ff ff       	jmp    80106810 <alltraps>

8010781a <vector221>:
.globl vector221
vector221:
  pushl $0
8010781a:	6a 00                	push   $0x0
  pushl $221
8010781c:	68 dd 00 00 00       	push   $0xdd
  jmp alltraps
80107821:	e9 ea ef ff ff       	jmp    80106810 <alltraps>

80107826 <vector222>:
.globl vector222
vector222:
  pushl $0
80107826:	6a 00                	push   $0x0
  pushl $222
80107828:	68 de 00 00 00       	push   $0xde
  jmp alltraps
8010782d:	e9 de ef ff ff       	jmp    80106810 <alltraps>

80107832 <vector223>:
.globl vector223
vector223:
  pushl $0
80107832:	6a 00                	push   $0x0
  pushl $223
80107834:	68 df 00 00 00       	push   $0xdf
  jmp alltraps
80107839:	e9 d2 ef ff ff       	jmp    80106810 <alltraps>

8010783e <vector224>:
.globl vector224
vector224:
  pushl $0
8010783e:	6a 00                	push   $0x0
  pushl $224
80107840:	68 e0 00 00 00       	push   $0xe0
  jmp alltraps
80107845:	e9 c6 ef ff ff       	jmp    80106810 <alltraps>

8010784a <vector225>:
.globl vector225
vector225:
  pushl $0
8010784a:	6a 00                	push   $0x0
  pushl $225
8010784c:	68 e1 00 00 00       	push   $0xe1
  jmp alltraps
80107851:	e9 ba ef ff ff       	jmp    80106810 <alltraps>

80107856 <vector226>:
.globl vector226
vector226:
  pushl $0
80107856:	6a 00                	push   $0x0
  pushl $226
80107858:	68 e2 00 00 00       	push   $0xe2
  jmp alltraps
8010785d:	e9 ae ef ff ff       	jmp    80106810 <alltraps>

80107862 <vector227>:
.globl vector227
vector227:
  pushl $0
80107862:	6a 00                	push   $0x0
  pushl $227
80107864:	68 e3 00 00 00       	push   $0xe3
  jmp alltraps
80107869:	e9 a2 ef ff ff       	jmp    80106810 <alltraps>

8010786e <vector228>:
.globl vector228
vector228:
  pushl $0
8010786e:	6a 00                	push   $0x0
  pushl $228
80107870:	68 e4 00 00 00       	push   $0xe4
  jmp alltraps
80107875:	e9 96 ef ff ff       	jmp    80106810 <alltraps>

8010787a <vector229>:
.globl vector229
vector229:
  pushl $0
8010787a:	6a 00                	push   $0x0
  pushl $229
8010787c:	68 e5 00 00 00       	push   $0xe5
  jmp alltraps
80107881:	e9 8a ef ff ff       	jmp    80106810 <alltraps>

80107886 <vector230>:
.globl vector230
vector230:
  pushl $0
80107886:	6a 00                	push   $0x0
  pushl $230
80107888:	68 e6 00 00 00       	push   $0xe6
  jmp alltraps
8010788d:	e9 7e ef ff ff       	jmp    80106810 <alltraps>

80107892 <vector231>:
.globl vector231
vector231:
  pushl $0
80107892:	6a 00                	push   $0x0
  pushl $231
80107894:	68 e7 00 00 00       	push   $0xe7
  jmp alltraps
80107899:	e9 72 ef ff ff       	jmp    80106810 <alltraps>

8010789e <vector232>:
.globl vector232
vector232:
  pushl $0
8010789e:	6a 00                	push   $0x0
  pushl $232
801078a0:	68 e8 00 00 00       	push   $0xe8
  jmp alltraps
801078a5:	e9 66 ef ff ff       	jmp    80106810 <alltraps>

801078aa <vector233>:
.globl vector233
vector233:
  pushl $0
801078aa:	6a 00                	push   $0x0
  pushl $233
801078ac:	68 e9 00 00 00       	push   $0xe9
  jmp alltraps
801078b1:	e9 5a ef ff ff       	jmp    80106810 <alltraps>

801078b6 <vector234>:
.globl vector234
vector234:
  pushl $0
801078b6:	6a 00                	push   $0x0
  pushl $234
801078b8:	68 ea 00 00 00       	push   $0xea
  jmp alltraps
801078bd:	e9 4e ef ff ff       	jmp    80106810 <alltraps>

801078c2 <vector235>:
.globl vector235
vector235:
  pushl $0
801078c2:	6a 00                	push   $0x0
  pushl $235
801078c4:	68 eb 00 00 00       	push   $0xeb
  jmp alltraps
801078c9:	e9 42 ef ff ff       	jmp    80106810 <alltraps>

801078ce <vector236>:
.globl vector236
vector236:
  pushl $0
801078ce:	6a 00                	push   $0x0
  pushl $236
801078d0:	68 ec 00 00 00       	push   $0xec
  jmp alltraps
801078d5:	e9 36 ef ff ff       	jmp    80106810 <alltraps>

801078da <vector237>:
.globl vector237
vector237:
  pushl $0
801078da:	6a 00                	push   $0x0
  pushl $237
801078dc:	68 ed 00 00 00       	push   $0xed
  jmp alltraps
801078e1:	e9 2a ef ff ff       	jmp    80106810 <alltraps>

801078e6 <vector238>:
.globl vector238
vector238:
  pushl $0
801078e6:	6a 00                	push   $0x0
  pushl $238
801078e8:	68 ee 00 00 00       	push   $0xee
  jmp alltraps
801078ed:	e9 1e ef ff ff       	jmp    80106810 <alltraps>

801078f2 <vector239>:
.globl vector239
vector239:
  pushl $0
801078f2:	6a 00                	push   $0x0
  pushl $239
801078f4:	68 ef 00 00 00       	push   $0xef
  jmp alltraps
801078f9:	e9 12 ef ff ff       	jmp    80106810 <alltraps>

801078fe <vector240>:
.globl vector240
vector240:
  pushl $0
801078fe:	6a 00                	push   $0x0
  pushl $240
80107900:	68 f0 00 00 00       	push   $0xf0
  jmp alltraps
80107905:	e9 06 ef ff ff       	jmp    80106810 <alltraps>

8010790a <vector241>:
.globl vector241
vector241:
  pushl $0
8010790a:	6a 00                	push   $0x0
  pushl $241
8010790c:	68 f1 00 00 00       	push   $0xf1
  jmp alltraps
80107911:	e9 fa ee ff ff       	jmp    80106810 <alltraps>

80107916 <vector242>:
.globl vector242
vector242:
  pushl $0
80107916:	6a 00                	push   $0x0
  pushl $242
80107918:	68 f2 00 00 00       	push   $0xf2
  jmp alltraps
8010791d:	e9 ee ee ff ff       	jmp    80106810 <alltraps>

80107922 <vector243>:
.globl vector243
vector243:
  pushl $0
80107922:	6a 00                	push   $0x0
  pushl $243
80107924:	68 f3 00 00 00       	push   $0xf3
  jmp alltraps
80107929:	e9 e2 ee ff ff       	jmp    80106810 <alltraps>

8010792e <vector244>:
.globl vector244
vector244:
  pushl $0
8010792e:	6a 00                	push   $0x0
  pushl $244
80107930:	68 f4 00 00 00       	push   $0xf4
  jmp alltraps
80107935:	e9 d6 ee ff ff       	jmp    80106810 <alltraps>

8010793a <vector245>:
.globl vector245
vector245:
  pushl $0
8010793a:	6a 00                	push   $0x0
  pushl $245
8010793c:	68 f5 00 00 00       	push   $0xf5
  jmp alltraps
80107941:	e9 ca ee ff ff       	jmp    80106810 <alltraps>

80107946 <vector246>:
.globl vector246
vector246:
  pushl $0
80107946:	6a 00                	push   $0x0
  pushl $246
80107948:	68 f6 00 00 00       	push   $0xf6
  jmp alltraps
8010794d:	e9 be ee ff ff       	jmp    80106810 <alltraps>

80107952 <vector247>:
.globl vector247
vector247:
  pushl $0
80107952:	6a 00                	push   $0x0
  pushl $247
80107954:	68 f7 00 00 00       	push   $0xf7
  jmp alltraps
80107959:	e9 b2 ee ff ff       	jmp    80106810 <alltraps>

8010795e <vector248>:
.globl vector248
vector248:
  pushl $0
8010795e:	6a 00                	push   $0x0
  pushl $248
80107960:	68 f8 00 00 00       	push   $0xf8
  jmp alltraps
80107965:	e9 a6 ee ff ff       	jmp    80106810 <alltraps>

8010796a <vector249>:
.globl vector249
vector249:
  pushl $0
8010796a:	6a 00                	push   $0x0
  pushl $249
8010796c:	68 f9 00 00 00       	push   $0xf9
  jmp alltraps
80107971:	e9 9a ee ff ff       	jmp    80106810 <alltraps>

80107976 <vector250>:
.globl vector250
vector250:
  pushl $0
80107976:	6a 00                	push   $0x0
  pushl $250
80107978:	68 fa 00 00 00       	push   $0xfa
  jmp alltraps
8010797d:	e9 8e ee ff ff       	jmp    80106810 <alltraps>

80107982 <vector251>:
.globl vector251
vector251:
  pushl $0
80107982:	6a 00                	push   $0x0
  pushl $251
80107984:	68 fb 00 00 00       	push   $0xfb
  jmp alltraps
80107989:	e9 82 ee ff ff       	jmp    80106810 <alltraps>

8010798e <vector252>:
.globl vector252
vector252:
  pushl $0
8010798e:	6a 00                	push   $0x0
  pushl $252
80107990:	68 fc 00 00 00       	push   $0xfc
  jmp alltraps
80107995:	e9 76 ee ff ff       	jmp    80106810 <alltraps>

8010799a <vector253>:
.globl vector253
vector253:
  pushl $0
8010799a:	6a 00                	push   $0x0
  pushl $253
8010799c:	68 fd 00 00 00       	push   $0xfd
  jmp alltraps
801079a1:	e9 6a ee ff ff       	jmp    80106810 <alltraps>

801079a6 <vector254>:
.globl vector254
vector254:
  pushl $0
801079a6:	6a 00                	push   $0x0
  pushl $254
801079a8:	68 fe 00 00 00       	push   $0xfe
  jmp alltraps
801079ad:	e9 5e ee ff ff       	jmp    80106810 <alltraps>

801079b2 <vector255>:
.globl vector255
vector255:
  pushl $0
801079b2:	6a 00                	push   $0x0
  pushl $255
801079b4:	68 ff 00 00 00       	push   $0xff
  jmp alltraps
801079b9:	e9 52 ee ff ff       	jmp    80106810 <alltraps>

801079be <lgdt>:
{
801079be:	55                   	push   %ebp
801079bf:	89 e5                	mov    %esp,%ebp
801079c1:	83 ec 10             	sub    $0x10,%esp
  pd[0] = size-1;
801079c4:	8b 45 0c             	mov    0xc(%ebp),%eax
801079c7:	83 e8 01             	sub    $0x1,%eax
801079ca:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
801079ce:	8b 45 08             	mov    0x8(%ebp),%eax
801079d1:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
801079d5:	8b 45 08             	mov    0x8(%ebp),%eax
801079d8:	c1 e8 10             	shr    $0x10,%eax
801079db:	66 89 45 fe          	mov    %ax,-0x2(%ebp)
  asm volatile("lgdt (%0)" : : "r" (pd));
801079df:	8d 45 fa             	lea    -0x6(%ebp),%eax
801079e2:	0f 01 10             	lgdtl  (%eax)
}
801079e5:	90                   	nop
801079e6:	c9                   	leave
801079e7:	c3                   	ret

801079e8 <ltr>:
{
801079e8:	55                   	push   %ebp
801079e9:	89 e5                	mov    %esp,%ebp
801079eb:	83 ec 04             	sub    $0x4,%esp
801079ee:	8b 45 08             	mov    0x8(%ebp),%eax
801079f1:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  asm volatile("ltr %0" : : "r" (sel));
801079f5:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
801079f9:	0f 00 d8             	ltr    %eax
}
801079fc:	90                   	nop
801079fd:	c9                   	leave
801079fe:	c3                   	ret

801079ff <loadgs>:
{
801079ff:	55                   	push   %ebp
80107a00:	89 e5                	mov    %esp,%ebp
80107a02:	83 ec 04             	sub    $0x4,%esp
80107a05:	8b 45 08             	mov    0x8(%ebp),%eax
80107a08:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  asm volatile("movw %0, %%gs" : : "r" (v));
80107a0c:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80107a10:	8e e8                	mov    %eax,%gs
}
80107a12:	90                   	nop
80107a13:	c9                   	leave
80107a14:	c3                   	ret

80107a15 <lcr3>:
{
80107a15:	55                   	push   %ebp
80107a16:	89 e5                	mov    %esp,%ebp
  asm volatile("movl %0,%%cr3" : : "r" (val));
80107a18:	8b 45 08             	mov    0x8(%ebp),%eax
80107a1b:	0f 22 d8             	mov    %eax,%cr3
}
80107a1e:	90                   	nop
80107a1f:	5d                   	pop    %ebp
80107a20:	c3                   	ret

80107a21 <v2p>:
80107a21:	55                   	push   %ebp
80107a22:	89 e5                	mov    %esp,%ebp
80107a24:	8b 45 08             	mov    0x8(%ebp),%eax
80107a27:	05 00 00 00 80       	add    $0x80000000,%eax
80107a2c:	5d                   	pop    %ebp
80107a2d:	c3                   	ret

80107a2e <p2v>:
static inline void *p2v(uint a) { return (void *) ((a) + KERNBASE); }
80107a2e:	55                   	push   %ebp
80107a2f:	89 e5                	mov    %esp,%ebp
80107a31:	8b 45 08             	mov    0x8(%ebp),%eax
80107a34:	05 00 00 00 80       	add    $0x80000000,%eax
80107a39:	5d                   	pop    %ebp
80107a3a:	c3                   	ret

80107a3b <seginit>:

// Set up CPU's kernel segment descriptors.
// Run once on entry on each CPU.
void
seginit(void)
{
80107a3b:	55                   	push   %ebp
80107a3c:	89 e5                	mov    %esp,%ebp
80107a3e:	53                   	push   %ebx
80107a3f:	83 ec 14             	sub    $0x14,%esp

  // Map "logical" addresses to virtual addresses using identity map.
  // Cannot share a CODE descriptor for both kernel and user
  // because it would have to have DPL_USR, but the CPU forbids
  // an interrupt from CPL=0 to DPL=3.
  c = &cpus[cpunum()];
80107a42:	e8 b0 b5 ff ff       	call   80102ff7 <cpunum>
80107a47:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
80107a4d:	05 60 13 11 80       	add    $0x80111360,%eax
80107a52:	89 45 f4             	mov    %eax,-0xc(%ebp)
  c->gdt[SEG_KCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, 0);
80107a55:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a58:	66 c7 40 78 ff ff    	movw   $0xffff,0x78(%eax)
80107a5e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a61:	66 c7 40 7a 00 00    	movw   $0x0,0x7a(%eax)
80107a67:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a6a:	c6 40 7c 00          	movb   $0x0,0x7c(%eax)
80107a6e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a71:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80107a75:	83 e2 f0             	and    $0xfffffff0,%edx
80107a78:	83 ca 0a             	or     $0xa,%edx
80107a7b:	88 50 7d             	mov    %dl,0x7d(%eax)
80107a7e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a81:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80107a85:	83 ca 10             	or     $0x10,%edx
80107a88:	88 50 7d             	mov    %dl,0x7d(%eax)
80107a8b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a8e:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80107a92:	83 e2 9f             	and    $0xffffff9f,%edx
80107a95:	88 50 7d             	mov    %dl,0x7d(%eax)
80107a98:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a9b:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80107a9f:	83 ca 80             	or     $0xffffff80,%edx
80107aa2:	88 50 7d             	mov    %dl,0x7d(%eax)
80107aa5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107aa8:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107aac:	83 ca 0f             	or     $0xf,%edx
80107aaf:	88 50 7e             	mov    %dl,0x7e(%eax)
80107ab2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ab5:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107ab9:	83 e2 ef             	and    $0xffffffef,%edx
80107abc:	88 50 7e             	mov    %dl,0x7e(%eax)
80107abf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ac2:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107ac6:	83 e2 df             	and    $0xffffffdf,%edx
80107ac9:	88 50 7e             	mov    %dl,0x7e(%eax)
80107acc:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107acf:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107ad3:	83 ca 40             	or     $0x40,%edx
80107ad6:	88 50 7e             	mov    %dl,0x7e(%eax)
80107ad9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107adc:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107ae0:	83 ca 80             	or     $0xffffff80,%edx
80107ae3:	88 50 7e             	mov    %dl,0x7e(%eax)
80107ae6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ae9:	c6 40 7f 00          	movb   $0x0,0x7f(%eax)
  c->gdt[SEG_KDATA] = SEG(STA_W, 0, 0xffffffff, 0);
80107aed:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107af0:	66 c7 80 80 00 00 00 	movw   $0xffff,0x80(%eax)
80107af7:	ff ff 
80107af9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107afc:	66 c7 80 82 00 00 00 	movw   $0x0,0x82(%eax)
80107b03:	00 00 
80107b05:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b08:	c6 80 84 00 00 00 00 	movb   $0x0,0x84(%eax)
80107b0f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b12:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80107b19:	83 e2 f0             	and    $0xfffffff0,%edx
80107b1c:	83 ca 02             	or     $0x2,%edx
80107b1f:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80107b25:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b28:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80107b2f:	83 ca 10             	or     $0x10,%edx
80107b32:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80107b38:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b3b:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80107b42:	83 e2 9f             	and    $0xffffff9f,%edx
80107b45:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80107b4b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b4e:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80107b55:	83 ca 80             	or     $0xffffff80,%edx
80107b58:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80107b5e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b61:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107b68:	83 ca 0f             	or     $0xf,%edx
80107b6b:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107b71:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b74:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107b7b:	83 e2 ef             	and    $0xffffffef,%edx
80107b7e:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107b84:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b87:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107b8e:	83 e2 df             	and    $0xffffffdf,%edx
80107b91:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107b97:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b9a:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107ba1:	83 ca 40             	or     $0x40,%edx
80107ba4:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107baa:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107bad:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107bb4:	83 ca 80             	or     $0xffffff80,%edx
80107bb7:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107bbd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107bc0:	c6 80 87 00 00 00 00 	movb   $0x0,0x87(%eax)
  c->gdt[SEG_UCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, DPL_USER);
80107bc7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107bca:	66 c7 80 90 00 00 00 	movw   $0xffff,0x90(%eax)
80107bd1:	ff ff 
80107bd3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107bd6:	66 c7 80 92 00 00 00 	movw   $0x0,0x92(%eax)
80107bdd:	00 00 
80107bdf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107be2:	c6 80 94 00 00 00 00 	movb   $0x0,0x94(%eax)
80107be9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107bec:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80107bf3:	83 e2 f0             	and    $0xfffffff0,%edx
80107bf6:	83 ca 0a             	or     $0xa,%edx
80107bf9:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107bff:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c02:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80107c09:	83 ca 10             	or     $0x10,%edx
80107c0c:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107c12:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c15:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80107c1c:	83 ca 60             	or     $0x60,%edx
80107c1f:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107c25:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c28:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80107c2f:	83 ca 80             	or     $0xffffff80,%edx
80107c32:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107c38:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c3b:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107c42:	83 ca 0f             	or     $0xf,%edx
80107c45:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107c4b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c4e:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107c55:	83 e2 ef             	and    $0xffffffef,%edx
80107c58:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107c5e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c61:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107c68:	83 e2 df             	and    $0xffffffdf,%edx
80107c6b:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107c71:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c74:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107c7b:	83 ca 40             	or     $0x40,%edx
80107c7e:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107c84:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c87:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107c8e:	83 ca 80             	or     $0xffffff80,%edx
80107c91:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107c97:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c9a:	c6 80 97 00 00 00 00 	movb   $0x0,0x97(%eax)
  c->gdt[SEG_UDATA] = SEG(STA_W, 0, 0xffffffff, DPL_USER);
80107ca1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ca4:	66 c7 80 98 00 00 00 	movw   $0xffff,0x98(%eax)
80107cab:	ff ff 
80107cad:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107cb0:	66 c7 80 9a 00 00 00 	movw   $0x0,0x9a(%eax)
80107cb7:	00 00 
80107cb9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107cbc:	c6 80 9c 00 00 00 00 	movb   $0x0,0x9c(%eax)
80107cc3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107cc6:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
80107ccd:	83 e2 f0             	and    $0xfffffff0,%edx
80107cd0:	83 ca 02             	or     $0x2,%edx
80107cd3:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
80107cd9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107cdc:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
80107ce3:	83 ca 10             	or     $0x10,%edx
80107ce6:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
80107cec:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107cef:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
80107cf6:	83 ca 60             	or     $0x60,%edx
80107cf9:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
80107cff:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d02:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
80107d09:	83 ca 80             	or     $0xffffff80,%edx
80107d0c:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
80107d12:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d15:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
80107d1c:	83 ca 0f             	or     $0xf,%edx
80107d1f:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
80107d25:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d28:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
80107d2f:	83 e2 ef             	and    $0xffffffef,%edx
80107d32:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
80107d38:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d3b:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
80107d42:	83 e2 df             	and    $0xffffffdf,%edx
80107d45:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
80107d4b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d4e:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
80107d55:	83 ca 40             	or     $0x40,%edx
80107d58:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
80107d5e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d61:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
80107d68:	83 ca 80             	or     $0xffffff80,%edx
80107d6b:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
80107d71:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d74:	c6 80 9f 00 00 00 00 	movb   $0x0,0x9f(%eax)

  // Map cpu, and curproc
  c->gdt[SEG_KCPU] = SEG(STA_W, &c->cpu, 8, 0);
80107d7b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d7e:	05 b4 00 00 00       	add    $0xb4,%eax
80107d83:	89 c3                	mov    %eax,%ebx
80107d85:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d88:	05 b4 00 00 00       	add    $0xb4,%eax
80107d8d:	c1 e8 10             	shr    $0x10,%eax
80107d90:	89 c2                	mov    %eax,%edx
80107d92:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d95:	05 b4 00 00 00       	add    $0xb4,%eax
80107d9a:	c1 e8 18             	shr    $0x18,%eax
80107d9d:	89 c1                	mov    %eax,%ecx
80107d9f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107da2:	66 c7 80 88 00 00 00 	movw   $0x0,0x88(%eax)
80107da9:	00 00 
80107dab:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107dae:	66 89 98 8a 00 00 00 	mov    %bx,0x8a(%eax)
80107db5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107db8:	88 90 8c 00 00 00    	mov    %dl,0x8c(%eax)
80107dbe:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107dc1:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
80107dc8:	83 e2 f0             	and    $0xfffffff0,%edx
80107dcb:	83 ca 02             	or     $0x2,%edx
80107dce:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80107dd4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107dd7:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
80107dde:	83 ca 10             	or     $0x10,%edx
80107de1:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80107de7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107dea:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
80107df1:	83 e2 9f             	and    $0xffffff9f,%edx
80107df4:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80107dfa:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107dfd:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
80107e04:	83 ca 80             	or     $0xffffff80,%edx
80107e07:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80107e0d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e10:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80107e17:	83 e2 f0             	and    $0xfffffff0,%edx
80107e1a:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80107e20:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e23:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80107e2a:	83 e2 ef             	and    $0xffffffef,%edx
80107e2d:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80107e33:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e36:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80107e3d:	83 e2 df             	and    $0xffffffdf,%edx
80107e40:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80107e46:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e49:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80107e50:	83 ca 40             	or     $0x40,%edx
80107e53:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80107e59:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e5c:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80107e63:	83 ca 80             	or     $0xffffff80,%edx
80107e66:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80107e6c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e6f:	88 88 8f 00 00 00    	mov    %cl,0x8f(%eax)

  lgdt(c->gdt, sizeof(c->gdt));
80107e75:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e78:	83 c0 70             	add    $0x70,%eax
80107e7b:	83 ec 08             	sub    $0x8,%esp
80107e7e:	6a 38                	push   $0x38
80107e80:	50                   	push   %eax
80107e81:	e8 38 fb ff ff       	call   801079be <lgdt>
80107e86:	83 c4 10             	add    $0x10,%esp
  loadgs(SEG_KCPU << 3);
80107e89:	83 ec 0c             	sub    $0xc,%esp
80107e8c:	6a 18                	push   $0x18
80107e8e:	e8 6c fb ff ff       	call   801079ff <loadgs>
80107e93:	83 c4 10             	add    $0x10,%esp
  
  // Initialize cpu-local storage.
  cpu = c;
80107e96:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e99:	65 a3 00 00 00 00    	mov    %eax,%gs:0x0
  proc = 0;
80107e9f:	65 c7 05 04 00 00 00 	movl   $0x0,%gs:0x4
80107ea6:	00 00 00 00 
}
80107eaa:	90                   	nop
80107eab:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80107eae:	c9                   	leave
80107eaf:	c3                   	ret

80107eb0 <walkpgdir>:
// Return the address of the PTE in page table pgdir
// that corresponds to virtual address va.  If alloc!=0,
// create any required page table pages.
static pte_t *
walkpgdir(pde_t *pgdir, const void *va, int alloc)
{
80107eb0:	55                   	push   %ebp
80107eb1:	89 e5                	mov    %esp,%ebp
80107eb3:	83 ec 18             	sub    $0x18,%esp
  pde_t *pde;
  pte_t *pgtab;

  pde = &pgdir[PDX(va)];
80107eb6:	8b 45 0c             	mov    0xc(%ebp),%eax
80107eb9:	c1 e8 16             	shr    $0x16,%eax
80107ebc:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80107ec3:	8b 45 08             	mov    0x8(%ebp),%eax
80107ec6:	01 d0                	add    %edx,%eax
80107ec8:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(*pde & PTE_P){
80107ecb:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107ece:	8b 00                	mov    (%eax),%eax
80107ed0:	83 e0 01             	and    $0x1,%eax
80107ed3:	85 c0                	test   %eax,%eax
80107ed5:	74 18                	je     80107eef <walkpgdir+0x3f>
    pgtab = (pte_t*)p2v(PTE_ADDR(*pde));
80107ed7:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107eda:	8b 00                	mov    (%eax),%eax
80107edc:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107ee1:	50                   	push   %eax
80107ee2:	e8 47 fb ff ff       	call   80107a2e <p2v>
80107ee7:	83 c4 04             	add    $0x4,%esp
80107eea:	89 45 f4             	mov    %eax,-0xc(%ebp)
80107eed:	eb 48                	jmp    80107f37 <walkpgdir+0x87>
  } else {
    if(!alloc || (pgtab = (pte_t*)kalloc()) == 0)
80107eef:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80107ef3:	74 0e                	je     80107f03 <walkpgdir+0x53>
80107ef5:	e8 8c ad ff ff       	call   80102c86 <kalloc>
80107efa:	89 45 f4             	mov    %eax,-0xc(%ebp)
80107efd:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80107f01:	75 07                	jne    80107f0a <walkpgdir+0x5a>
      return 0;
80107f03:	b8 00 00 00 00       	mov    $0x0,%eax
80107f08:	eb 44                	jmp    80107f4e <walkpgdir+0x9e>
    // Make sure all those PTE_P bits are zero.
    memset(pgtab, 0, PGSIZE);
80107f0a:	83 ec 04             	sub    $0x4,%esp
80107f0d:	68 00 10 00 00       	push   $0x1000
80107f12:	6a 00                	push   $0x0
80107f14:	ff 75 f4             	push   -0xc(%ebp)
80107f17:	e8 c7 d3 ff ff       	call   801052e3 <memset>
80107f1c:	83 c4 10             	add    $0x10,%esp
    // The permissions here are overly generous, but they can
    // be further restricted by the permissions in the page table 
    // entries, if necessary.
    *pde = v2p(pgtab) | PTE_P | PTE_W | PTE_U;
80107f1f:	83 ec 0c             	sub    $0xc,%esp
80107f22:	ff 75 f4             	push   -0xc(%ebp)
80107f25:	e8 f7 fa ff ff       	call   80107a21 <v2p>
80107f2a:	83 c4 10             	add    $0x10,%esp
80107f2d:	83 c8 07             	or     $0x7,%eax
80107f30:	89 c2                	mov    %eax,%edx
80107f32:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107f35:	89 10                	mov    %edx,(%eax)
  }
  return &pgtab[PTX(va)];
80107f37:	8b 45 0c             	mov    0xc(%ebp),%eax
80107f3a:	c1 e8 0c             	shr    $0xc,%eax
80107f3d:	25 ff 03 00 00       	and    $0x3ff,%eax
80107f42:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80107f49:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f4c:	01 d0                	add    %edx,%eax
}
80107f4e:	c9                   	leave
80107f4f:	c3                   	ret

80107f50 <mappages>:
// Create PTEs for virtual addresses starting at va that refer to
// physical addresses starting at pa. va and size might not
// be page-aligned.
int
mappages(pde_t *pgdir, void *va, uint size, uint pa, int perm)
{
80107f50:	55                   	push   %ebp
80107f51:	89 e5                	mov    %esp,%ebp
80107f53:	83 ec 18             	sub    $0x18,%esp
  char *a, *last;
  pte_t *pte;
  
  a = (char*)PGROUNDDOWN((uint)va);
80107f56:	8b 45 0c             	mov    0xc(%ebp),%eax
80107f59:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107f5e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  last = (char*)PGROUNDDOWN(((uint)va) + size - 1);
80107f61:	8b 55 0c             	mov    0xc(%ebp),%edx
80107f64:	8b 45 10             	mov    0x10(%ebp),%eax
80107f67:	01 d0                	add    %edx,%eax
80107f69:	83 e8 01             	sub    $0x1,%eax
80107f6c:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107f71:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(;;){
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
80107f74:	83 ec 04             	sub    $0x4,%esp
80107f77:	6a 01                	push   $0x1
80107f79:	ff 75 f4             	push   -0xc(%ebp)
80107f7c:	ff 75 08             	push   0x8(%ebp)
80107f7f:	e8 2c ff ff ff       	call   80107eb0 <walkpgdir>
80107f84:	83 c4 10             	add    $0x10,%esp
80107f87:	89 45 ec             	mov    %eax,-0x14(%ebp)
80107f8a:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80107f8e:	75 07                	jne    80107f97 <mappages+0x47>
      return -1;
80107f90:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107f95:	eb 47                	jmp    80107fde <mappages+0x8e>
    if(*pte & PTE_P)
80107f97:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107f9a:	8b 00                	mov    (%eax),%eax
80107f9c:	83 e0 01             	and    $0x1,%eax
80107f9f:	85 c0                	test   %eax,%eax
80107fa1:	74 0d                	je     80107fb0 <mappages+0x60>
      panic("remap");
80107fa3:	83 ec 0c             	sub    $0xc,%esp
80107fa6:	68 00 8f 10 80       	push   $0x80108f00
80107fab:	e8 c9 85 ff ff       	call   80100579 <panic>
    *pte = pa | perm | PTE_P;
80107fb0:	8b 45 18             	mov    0x18(%ebp),%eax
80107fb3:	0b 45 14             	or     0x14(%ebp),%eax
80107fb6:	83 c8 01             	or     $0x1,%eax
80107fb9:	89 c2                	mov    %eax,%edx
80107fbb:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107fbe:	89 10                	mov    %edx,(%eax)
    if(a == last)
80107fc0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107fc3:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80107fc6:	74 10                	je     80107fd8 <mappages+0x88>
      break;
    a += PGSIZE;
80107fc8:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
    pa += PGSIZE;
80107fcf:	81 45 14 00 10 00 00 	addl   $0x1000,0x14(%ebp)
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
80107fd6:	eb 9c                	jmp    80107f74 <mappages+0x24>
      break;
80107fd8:	90                   	nop
  }
  return 0;
80107fd9:	b8 00 00 00 00       	mov    $0x0,%eax
}
80107fde:	c9                   	leave
80107fdf:	c3                   	ret

80107fe0 <setupkvm>:
};

// Set up kernel part of a page table.
pde_t*
setupkvm(void)
{
80107fe0:	55                   	push   %ebp
80107fe1:	89 e5                	mov    %esp,%ebp
80107fe3:	53                   	push   %ebx
80107fe4:	83 ec 14             	sub    $0x14,%esp
  pde_t *pgdir;
  struct kmap *k;

  if((pgdir = (pde_t*)kalloc()) == 0)
80107fe7:	e8 9a ac ff ff       	call   80102c86 <kalloc>
80107fec:	89 45 f0             	mov    %eax,-0x10(%ebp)
80107fef:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80107ff3:	75 0a                	jne    80107fff <setupkvm+0x1f>
    return 0;
80107ff5:	b8 00 00 00 00       	mov    $0x0,%eax
80107ffa:	e9 8e 00 00 00       	jmp    8010808d <setupkvm+0xad>
  memset(pgdir, 0, PGSIZE);
80107fff:	83 ec 04             	sub    $0x4,%esp
80108002:	68 00 10 00 00       	push   $0x1000
80108007:	6a 00                	push   $0x0
80108009:	ff 75 f0             	push   -0x10(%ebp)
8010800c:	e8 d2 d2 ff ff       	call   801052e3 <memset>
80108011:	83 c4 10             	add    $0x10,%esp
  if (p2v(PHYSTOP) > (void*)DEVSPACE)
80108014:	83 ec 0c             	sub    $0xc,%esp
80108017:	68 00 00 00 0e       	push   $0xe000000
8010801c:	e8 0d fa ff ff       	call   80107a2e <p2v>
80108021:	83 c4 10             	add    $0x10,%esp
80108024:	3d 00 00 00 fe       	cmp    $0xfe000000,%eax
80108029:	76 0d                	jbe    80108038 <setupkvm+0x58>
    panic("PHYSTOP too high");
8010802b:	83 ec 0c             	sub    $0xc,%esp
8010802e:	68 06 8f 10 80       	push   $0x80108f06
80108033:	e8 41 85 ff ff       	call   80100579 <panic>
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
80108038:	c7 45 f4 c0 b4 10 80 	movl   $0x8010b4c0,-0xc(%ebp)
8010803f:	eb 40                	jmp    80108081 <setupkvm+0xa1>
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start, 
80108041:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108044:	8b 48 0c             	mov    0xc(%eax),%ecx
                (uint)k->phys_start, k->perm) < 0)
80108047:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010804a:	8b 50 04             	mov    0x4(%eax),%edx
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start, 
8010804d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108050:	8b 58 08             	mov    0x8(%eax),%ebx
80108053:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108056:	8b 40 04             	mov    0x4(%eax),%eax
80108059:	29 c3                	sub    %eax,%ebx
8010805b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010805e:	8b 00                	mov    (%eax),%eax
80108060:	83 ec 0c             	sub    $0xc,%esp
80108063:	51                   	push   %ecx
80108064:	52                   	push   %edx
80108065:	53                   	push   %ebx
80108066:	50                   	push   %eax
80108067:	ff 75 f0             	push   -0x10(%ebp)
8010806a:	e8 e1 fe ff ff       	call   80107f50 <mappages>
8010806f:	83 c4 20             	add    $0x20,%esp
80108072:	85 c0                	test   %eax,%eax
80108074:	79 07                	jns    8010807d <setupkvm+0x9d>
      return 0;
80108076:	b8 00 00 00 00       	mov    $0x0,%eax
8010807b:	eb 10                	jmp    8010808d <setupkvm+0xad>
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
8010807d:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
80108081:	81 7d f4 00 b5 10 80 	cmpl   $0x8010b500,-0xc(%ebp)
80108088:	72 b7                	jb     80108041 <setupkvm+0x61>
  return pgdir;
8010808a:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
8010808d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80108090:	c9                   	leave
80108091:	c3                   	ret

80108092 <kvmalloc>:

// Allocate one page table for the machine for the kernel address
// space for scheduler processes.
void
kvmalloc(void)
{
80108092:	55                   	push   %ebp
80108093:	89 e5                	mov    %esp,%ebp
80108095:	83 ec 08             	sub    $0x8,%esp
  kpgdir = setupkvm();
80108098:	e8 43 ff ff ff       	call   80107fe0 <setupkvm>
8010809d:	a3 00 41 11 80       	mov    %eax,0x80114100
  switchkvm();
801080a2:	e8 03 00 00 00       	call   801080aa <switchkvm>
}
801080a7:	90                   	nop
801080a8:	c9                   	leave
801080a9:	c3                   	ret

801080aa <switchkvm>:

// Switch h/w page table register to the kernel-only page table,
// for when no process is running.
void
switchkvm(void)
{
801080aa:	55                   	push   %ebp
801080ab:	89 e5                	mov    %esp,%ebp
  lcr3(v2p(kpgdir));   // switch to the kernel page table
801080ad:	a1 00 41 11 80       	mov    0x80114100,%eax
801080b2:	50                   	push   %eax
801080b3:	e8 69 f9 ff ff       	call   80107a21 <v2p>
801080b8:	83 c4 04             	add    $0x4,%esp
801080bb:	50                   	push   %eax
801080bc:	e8 54 f9 ff ff       	call   80107a15 <lcr3>
801080c1:	83 c4 04             	add    $0x4,%esp
}
801080c4:	90                   	nop
801080c5:	c9                   	leave
801080c6:	c3                   	ret

801080c7 <switchuvm>:

// Switch TSS and h/w page table to correspond to process p.
void
switchuvm(struct proc *p)
{
801080c7:	55                   	push   %ebp
801080c8:	89 e5                	mov    %esp,%ebp
801080ca:	56                   	push   %esi
801080cb:	53                   	push   %ebx
  pushcli();
801080cc:	e8 0c d1 ff ff       	call   801051dd <pushcli>
  cpu->gdt[SEG_TSS] = SEG16(STS_T32A, &cpu->ts, sizeof(cpu->ts)-1, 0);
801080d1:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801080d7:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
801080de:	83 c2 08             	add    $0x8,%edx
801080e1:	89 d6                	mov    %edx,%esi
801080e3:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
801080ea:	83 c2 08             	add    $0x8,%edx
801080ed:	c1 ea 10             	shr    $0x10,%edx
801080f0:	89 d3                	mov    %edx,%ebx
801080f2:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
801080f9:	83 c2 08             	add    $0x8,%edx
801080fc:	c1 ea 18             	shr    $0x18,%edx
801080ff:	89 d1                	mov    %edx,%ecx
80108101:	66 c7 80 a0 00 00 00 	movw   $0x67,0xa0(%eax)
80108108:	67 00 
8010810a:	66 89 b0 a2 00 00 00 	mov    %si,0xa2(%eax)
80108111:	88 98 a4 00 00 00    	mov    %bl,0xa4(%eax)
80108117:	0f b6 90 a5 00 00 00 	movzbl 0xa5(%eax),%edx
8010811e:	83 e2 f0             	and    $0xfffffff0,%edx
80108121:	83 ca 09             	or     $0x9,%edx
80108124:	88 90 a5 00 00 00    	mov    %dl,0xa5(%eax)
8010812a:	0f b6 90 a5 00 00 00 	movzbl 0xa5(%eax),%edx
80108131:	83 ca 10             	or     $0x10,%edx
80108134:	88 90 a5 00 00 00    	mov    %dl,0xa5(%eax)
8010813a:	0f b6 90 a5 00 00 00 	movzbl 0xa5(%eax),%edx
80108141:	83 e2 9f             	and    $0xffffff9f,%edx
80108144:	88 90 a5 00 00 00    	mov    %dl,0xa5(%eax)
8010814a:	0f b6 90 a5 00 00 00 	movzbl 0xa5(%eax),%edx
80108151:	83 ca 80             	or     $0xffffff80,%edx
80108154:	88 90 a5 00 00 00    	mov    %dl,0xa5(%eax)
8010815a:	0f b6 90 a6 00 00 00 	movzbl 0xa6(%eax),%edx
80108161:	83 e2 f0             	and    $0xfffffff0,%edx
80108164:	88 90 a6 00 00 00    	mov    %dl,0xa6(%eax)
8010816a:	0f b6 90 a6 00 00 00 	movzbl 0xa6(%eax),%edx
80108171:	83 e2 ef             	and    $0xffffffef,%edx
80108174:	88 90 a6 00 00 00    	mov    %dl,0xa6(%eax)
8010817a:	0f b6 90 a6 00 00 00 	movzbl 0xa6(%eax),%edx
80108181:	83 e2 df             	and    $0xffffffdf,%edx
80108184:	88 90 a6 00 00 00    	mov    %dl,0xa6(%eax)
8010818a:	0f b6 90 a6 00 00 00 	movzbl 0xa6(%eax),%edx
80108191:	83 ca 40             	or     $0x40,%edx
80108194:	88 90 a6 00 00 00    	mov    %dl,0xa6(%eax)
8010819a:	0f b6 90 a6 00 00 00 	movzbl 0xa6(%eax),%edx
801081a1:	83 e2 7f             	and    $0x7f,%edx
801081a4:	88 90 a6 00 00 00    	mov    %dl,0xa6(%eax)
801081aa:	88 88 a7 00 00 00    	mov    %cl,0xa7(%eax)
  cpu->gdt[SEG_TSS].s = 0;
801081b0:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801081b6:	0f b6 90 a5 00 00 00 	movzbl 0xa5(%eax),%edx
801081bd:	83 e2 ef             	and    $0xffffffef,%edx
801081c0:	88 90 a5 00 00 00    	mov    %dl,0xa5(%eax)
  cpu->ts.ss0 = SEG_KDATA << 3;
801081c6:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801081cc:	66 c7 40 10 10 00    	movw   $0x10,0x10(%eax)
  cpu->ts.esp0 = (uint)proc->kstack + KSTACKSIZE;
801081d2:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801081d8:	8b 40 08             	mov    0x8(%eax),%eax
801081db:	89 c2                	mov    %eax,%edx
801081dd:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801081e3:	81 c2 00 10 00 00    	add    $0x1000,%edx
801081e9:	89 50 0c             	mov    %edx,0xc(%eax)
  ltr(SEG_TSS << 3);
801081ec:	83 ec 0c             	sub    $0xc,%esp
801081ef:	6a 30                	push   $0x30
801081f1:	e8 f2 f7 ff ff       	call   801079e8 <ltr>
801081f6:	83 c4 10             	add    $0x10,%esp
  if(p->pgdir == 0)
801081f9:	8b 45 08             	mov    0x8(%ebp),%eax
801081fc:	8b 40 04             	mov    0x4(%eax),%eax
801081ff:	85 c0                	test   %eax,%eax
80108201:	75 0d                	jne    80108210 <switchuvm+0x149>
    panic("switchuvm: no pgdir");
80108203:	83 ec 0c             	sub    $0xc,%esp
80108206:	68 17 8f 10 80       	push   $0x80108f17
8010820b:	e8 69 83 ff ff       	call   80100579 <panic>
  lcr3(v2p(p->pgdir));  // switch to new address space
80108210:	8b 45 08             	mov    0x8(%ebp),%eax
80108213:	8b 40 04             	mov    0x4(%eax),%eax
80108216:	83 ec 0c             	sub    $0xc,%esp
80108219:	50                   	push   %eax
8010821a:	e8 02 f8 ff ff       	call   80107a21 <v2p>
8010821f:	83 c4 10             	add    $0x10,%esp
80108222:	83 ec 0c             	sub    $0xc,%esp
80108225:	50                   	push   %eax
80108226:	e8 ea f7 ff ff       	call   80107a15 <lcr3>
8010822b:	83 c4 10             	add    $0x10,%esp
  popcli();
8010822e:	e8 ef cf ff ff       	call   80105222 <popcli>
}
80108233:	90                   	nop
80108234:	8d 65 f8             	lea    -0x8(%ebp),%esp
80108237:	5b                   	pop    %ebx
80108238:	5e                   	pop    %esi
80108239:	5d                   	pop    %ebp
8010823a:	c3                   	ret

8010823b <inituvm>:

// Load the initcode into address 0 of pgdir.
// sz must be less than a page.
void
inituvm(pde_t *pgdir, char *init, uint sz)
{
8010823b:	55                   	push   %ebp
8010823c:	89 e5                	mov    %esp,%ebp
8010823e:	83 ec 18             	sub    $0x18,%esp
  char *mem;
  
  if(sz >= PGSIZE)
80108241:	81 7d 10 ff 0f 00 00 	cmpl   $0xfff,0x10(%ebp)
80108248:	76 0d                	jbe    80108257 <inituvm+0x1c>
    panic("inituvm: more than a page");
8010824a:	83 ec 0c             	sub    $0xc,%esp
8010824d:	68 2b 8f 10 80       	push   $0x80108f2b
80108252:	e8 22 83 ff ff       	call   80100579 <panic>
  mem = kalloc();
80108257:	e8 2a aa ff ff       	call   80102c86 <kalloc>
8010825c:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(mem, 0, PGSIZE);
8010825f:	83 ec 04             	sub    $0x4,%esp
80108262:	68 00 10 00 00       	push   $0x1000
80108267:	6a 00                	push   $0x0
80108269:	ff 75 f4             	push   -0xc(%ebp)
8010826c:	e8 72 d0 ff ff       	call   801052e3 <memset>
80108271:	83 c4 10             	add    $0x10,%esp
  mappages(pgdir, 0, PGSIZE, v2p(mem), PTE_W|PTE_U);
80108274:	83 ec 0c             	sub    $0xc,%esp
80108277:	ff 75 f4             	push   -0xc(%ebp)
8010827a:	e8 a2 f7 ff ff       	call   80107a21 <v2p>
8010827f:	83 c4 10             	add    $0x10,%esp
80108282:	83 ec 0c             	sub    $0xc,%esp
80108285:	6a 06                	push   $0x6
80108287:	50                   	push   %eax
80108288:	68 00 10 00 00       	push   $0x1000
8010828d:	6a 00                	push   $0x0
8010828f:	ff 75 08             	push   0x8(%ebp)
80108292:	e8 b9 fc ff ff       	call   80107f50 <mappages>
80108297:	83 c4 20             	add    $0x20,%esp
  memmove(mem, init, sz);
8010829a:	83 ec 04             	sub    $0x4,%esp
8010829d:	ff 75 10             	push   0x10(%ebp)
801082a0:	ff 75 0c             	push   0xc(%ebp)
801082a3:	ff 75 f4             	push   -0xc(%ebp)
801082a6:	e8 f7 d0 ff ff       	call   801053a2 <memmove>
801082ab:	83 c4 10             	add    $0x10,%esp
}
801082ae:	90                   	nop
801082af:	c9                   	leave
801082b0:	c3                   	ret

801082b1 <loaduvm>:

// Load a program segment into pgdir.  addr must be page-aligned
// and the pages from addr to addr+sz must already be mapped.
int
loaduvm(pde_t *pgdir, char *addr, struct inode *ip, uint offset, uint sz)
{
801082b1:	55                   	push   %ebp
801082b2:	89 e5                	mov    %esp,%ebp
801082b4:	53                   	push   %ebx
801082b5:	83 ec 14             	sub    $0x14,%esp
  uint i, pa, n;
  pte_t *pte;

  if((uint) addr % PGSIZE != 0)
801082b8:	8b 45 0c             	mov    0xc(%ebp),%eax
801082bb:	25 ff 0f 00 00       	and    $0xfff,%eax
801082c0:	85 c0                	test   %eax,%eax
801082c2:	74 0d                	je     801082d1 <loaduvm+0x20>
    panic("loaduvm: addr must be page aligned");
801082c4:	83 ec 0c             	sub    $0xc,%esp
801082c7:	68 48 8f 10 80       	push   $0x80108f48
801082cc:	e8 a8 82 ff ff       	call   80100579 <panic>
  for(i = 0; i < sz; i += PGSIZE){
801082d1:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801082d8:	e9 95 00 00 00       	jmp    80108372 <loaduvm+0xc1>
    if((pte = walkpgdir(pgdir, addr+i, 0)) == 0)
801082dd:	8b 55 0c             	mov    0xc(%ebp),%edx
801082e0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801082e3:	01 d0                	add    %edx,%eax
801082e5:	83 ec 04             	sub    $0x4,%esp
801082e8:	6a 00                	push   $0x0
801082ea:	50                   	push   %eax
801082eb:	ff 75 08             	push   0x8(%ebp)
801082ee:	e8 bd fb ff ff       	call   80107eb0 <walkpgdir>
801082f3:	83 c4 10             	add    $0x10,%esp
801082f6:	89 45 ec             	mov    %eax,-0x14(%ebp)
801082f9:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
801082fd:	75 0d                	jne    8010830c <loaduvm+0x5b>
      panic("loaduvm: address should exist");
801082ff:	83 ec 0c             	sub    $0xc,%esp
80108302:	68 6b 8f 10 80       	push   $0x80108f6b
80108307:	e8 6d 82 ff ff       	call   80100579 <panic>
    pa = PTE_ADDR(*pte);
8010830c:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010830f:	8b 00                	mov    (%eax),%eax
80108311:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108316:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(sz - i < PGSIZE)
80108319:	8b 45 18             	mov    0x18(%ebp),%eax
8010831c:	2b 45 f4             	sub    -0xc(%ebp),%eax
8010831f:	3d ff 0f 00 00       	cmp    $0xfff,%eax
80108324:	77 0b                	ja     80108331 <loaduvm+0x80>
      n = sz - i;
80108326:	8b 45 18             	mov    0x18(%ebp),%eax
80108329:	2b 45 f4             	sub    -0xc(%ebp),%eax
8010832c:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010832f:	eb 07                	jmp    80108338 <loaduvm+0x87>
    else
      n = PGSIZE;
80108331:	c7 45 f0 00 10 00 00 	movl   $0x1000,-0x10(%ebp)
    if(readi(ip, p2v(pa), offset+i, n) != n)
80108338:	8b 55 14             	mov    0x14(%ebp),%edx
8010833b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010833e:	8d 1c 02             	lea    (%edx,%eax,1),%ebx
80108341:	83 ec 0c             	sub    $0xc,%esp
80108344:	ff 75 e8             	push   -0x18(%ebp)
80108347:	e8 e2 f6 ff ff       	call   80107a2e <p2v>
8010834c:	83 c4 10             	add    $0x10,%esp
8010834f:	ff 75 f0             	push   -0x10(%ebp)
80108352:	53                   	push   %ebx
80108353:	50                   	push   %eax
80108354:	ff 75 10             	push   0x10(%ebp)
80108357:	e8 96 9b ff ff       	call   80101ef2 <readi>
8010835c:	83 c4 10             	add    $0x10,%esp
8010835f:	39 45 f0             	cmp    %eax,-0x10(%ebp)
80108362:	74 07                	je     8010836b <loaduvm+0xba>
      return -1;
80108364:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80108369:	eb 18                	jmp    80108383 <loaduvm+0xd2>
  for(i = 0; i < sz; i += PGSIZE){
8010836b:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80108372:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108375:	3b 45 18             	cmp    0x18(%ebp),%eax
80108378:	0f 82 5f ff ff ff    	jb     801082dd <loaduvm+0x2c>
  }
  return 0;
8010837e:	b8 00 00 00 00       	mov    $0x0,%eax
}
80108383:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80108386:	c9                   	leave
80108387:	c3                   	ret

80108388 <allocuvm>:

// Allocate page tables and physical memory to grow process from oldsz to
// newsz, which need not be page aligned.  Returns new size or 0 on error.
int
allocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
80108388:	55                   	push   %ebp
80108389:	89 e5                	mov    %esp,%ebp
8010838b:	83 ec 18             	sub    $0x18,%esp
  char *mem;
  uint a;

  if(newsz >= KERNBASE)
8010838e:	8b 45 10             	mov    0x10(%ebp),%eax
80108391:	85 c0                	test   %eax,%eax
80108393:	79 0a                	jns    8010839f <allocuvm+0x17>
    return 0;
80108395:	b8 00 00 00 00       	mov    $0x0,%eax
8010839a:	e9 ae 00 00 00       	jmp    8010844d <allocuvm+0xc5>
  if(newsz < oldsz)
8010839f:	8b 45 10             	mov    0x10(%ebp),%eax
801083a2:	3b 45 0c             	cmp    0xc(%ebp),%eax
801083a5:	73 08                	jae    801083af <allocuvm+0x27>
    return oldsz;
801083a7:	8b 45 0c             	mov    0xc(%ebp),%eax
801083aa:	e9 9e 00 00 00       	jmp    8010844d <allocuvm+0xc5>

  a = PGROUNDUP(oldsz);
801083af:	8b 45 0c             	mov    0xc(%ebp),%eax
801083b2:	05 ff 0f 00 00       	add    $0xfff,%eax
801083b7:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801083bc:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a < newsz; a += PGSIZE){
801083bf:	eb 7d                	jmp    8010843e <allocuvm+0xb6>
    mem = kalloc();
801083c1:	e8 c0 a8 ff ff       	call   80102c86 <kalloc>
801083c6:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(mem == 0){
801083c9:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801083cd:	75 2b                	jne    801083fa <allocuvm+0x72>
      cprintf("allocuvm out of memory\n");
801083cf:	83 ec 0c             	sub    $0xc,%esp
801083d2:	68 89 8f 10 80       	push   $0x80108f89
801083d7:	e8 e8 7f ff ff       	call   801003c4 <cprintf>
801083dc:	83 c4 10             	add    $0x10,%esp
      deallocuvm(pgdir, newsz, oldsz);
801083df:	83 ec 04             	sub    $0x4,%esp
801083e2:	ff 75 0c             	push   0xc(%ebp)
801083e5:	ff 75 10             	push   0x10(%ebp)
801083e8:	ff 75 08             	push   0x8(%ebp)
801083eb:	e8 5f 00 00 00       	call   8010844f <deallocuvm>
801083f0:	83 c4 10             	add    $0x10,%esp
      return 0;
801083f3:	b8 00 00 00 00       	mov    $0x0,%eax
801083f8:	eb 53                	jmp    8010844d <allocuvm+0xc5>
    }
    memset(mem, 0, PGSIZE);
801083fa:	83 ec 04             	sub    $0x4,%esp
801083fd:	68 00 10 00 00       	push   $0x1000
80108402:	6a 00                	push   $0x0
80108404:	ff 75 f0             	push   -0x10(%ebp)
80108407:	e8 d7 ce ff ff       	call   801052e3 <memset>
8010840c:	83 c4 10             	add    $0x10,%esp
    mappages(pgdir, (char*)a, PGSIZE, v2p(mem), PTE_W|PTE_U);
8010840f:	83 ec 0c             	sub    $0xc,%esp
80108412:	ff 75 f0             	push   -0x10(%ebp)
80108415:	e8 07 f6 ff ff       	call   80107a21 <v2p>
8010841a:	83 c4 10             	add    $0x10,%esp
8010841d:	8b 55 f4             	mov    -0xc(%ebp),%edx
80108420:	83 ec 0c             	sub    $0xc,%esp
80108423:	6a 06                	push   $0x6
80108425:	50                   	push   %eax
80108426:	68 00 10 00 00       	push   $0x1000
8010842b:	52                   	push   %edx
8010842c:	ff 75 08             	push   0x8(%ebp)
8010842f:	e8 1c fb ff ff       	call   80107f50 <mappages>
80108434:	83 c4 20             	add    $0x20,%esp
  for(; a < newsz; a += PGSIZE){
80108437:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
8010843e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108441:	3b 45 10             	cmp    0x10(%ebp),%eax
80108444:	0f 82 77 ff ff ff    	jb     801083c1 <allocuvm+0x39>
  }
  return newsz;
8010844a:	8b 45 10             	mov    0x10(%ebp),%eax
}
8010844d:	c9                   	leave
8010844e:	c3                   	ret

8010844f <deallocuvm>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
int
deallocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
8010844f:	55                   	push   %ebp
80108450:	89 e5                	mov    %esp,%ebp
80108452:	83 ec 18             	sub    $0x18,%esp
  pte_t *pte;
  uint a, pa;

  if(newsz >= oldsz)
80108455:	8b 45 10             	mov    0x10(%ebp),%eax
80108458:	3b 45 0c             	cmp    0xc(%ebp),%eax
8010845b:	72 08                	jb     80108465 <deallocuvm+0x16>
    return oldsz;
8010845d:	8b 45 0c             	mov    0xc(%ebp),%eax
80108460:	e9 a5 00 00 00       	jmp    8010850a <deallocuvm+0xbb>

  a = PGROUNDUP(newsz);
80108465:	8b 45 10             	mov    0x10(%ebp),%eax
80108468:	05 ff 0f 00 00       	add    $0xfff,%eax
8010846d:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108472:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a  < oldsz; a += PGSIZE){
80108475:	e9 81 00 00 00       	jmp    801084fb <deallocuvm+0xac>
    pte = walkpgdir(pgdir, (char*)a, 0);
8010847a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010847d:	83 ec 04             	sub    $0x4,%esp
80108480:	6a 00                	push   $0x0
80108482:	50                   	push   %eax
80108483:	ff 75 08             	push   0x8(%ebp)
80108486:	e8 25 fa ff ff       	call   80107eb0 <walkpgdir>
8010848b:	83 c4 10             	add    $0x10,%esp
8010848e:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(!pte)
80108491:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80108495:	75 09                	jne    801084a0 <deallocuvm+0x51>
      a += (NPTENTRIES - 1) * PGSIZE;
80108497:	81 45 f4 00 f0 3f 00 	addl   $0x3ff000,-0xc(%ebp)
8010849e:	eb 54                	jmp    801084f4 <deallocuvm+0xa5>
    else if((*pte & PTE_P) != 0){
801084a0:	8b 45 f0             	mov    -0x10(%ebp),%eax
801084a3:	8b 00                	mov    (%eax),%eax
801084a5:	83 e0 01             	and    $0x1,%eax
801084a8:	85 c0                	test   %eax,%eax
801084aa:	74 48                	je     801084f4 <deallocuvm+0xa5>
      pa = PTE_ADDR(*pte);
801084ac:	8b 45 f0             	mov    -0x10(%ebp),%eax
801084af:	8b 00                	mov    (%eax),%eax
801084b1:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801084b6:	89 45 ec             	mov    %eax,-0x14(%ebp)
      if(pa == 0)
801084b9:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
801084bd:	75 0d                	jne    801084cc <deallocuvm+0x7d>
        panic("kfree");
801084bf:	83 ec 0c             	sub    $0xc,%esp
801084c2:	68 a1 8f 10 80       	push   $0x80108fa1
801084c7:	e8 ad 80 ff ff       	call   80100579 <panic>
      char *v = p2v(pa);
801084cc:	83 ec 0c             	sub    $0xc,%esp
801084cf:	ff 75 ec             	push   -0x14(%ebp)
801084d2:	e8 57 f5 ff ff       	call   80107a2e <p2v>
801084d7:	83 c4 10             	add    $0x10,%esp
801084da:	89 45 e8             	mov    %eax,-0x18(%ebp)
      kfree(v);
801084dd:	83 ec 0c             	sub    $0xc,%esp
801084e0:	ff 75 e8             	push   -0x18(%ebp)
801084e3:	e8 f4 a6 ff ff       	call   80102bdc <kfree>
801084e8:	83 c4 10             	add    $0x10,%esp
      *pte = 0;
801084eb:	8b 45 f0             	mov    -0x10(%ebp),%eax
801084ee:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  for(; a  < oldsz; a += PGSIZE){
801084f4:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
801084fb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801084fe:	3b 45 0c             	cmp    0xc(%ebp),%eax
80108501:	0f 82 73 ff ff ff    	jb     8010847a <deallocuvm+0x2b>
    }
  }
  return newsz;
80108507:	8b 45 10             	mov    0x10(%ebp),%eax
}
8010850a:	c9                   	leave
8010850b:	c3                   	ret

8010850c <freevm>:

// Free a page table and all the physical memory pages
// in the user part.
void
freevm(pde_t *pgdir)
{
8010850c:	55                   	push   %ebp
8010850d:	89 e5                	mov    %esp,%ebp
8010850f:	83 ec 18             	sub    $0x18,%esp
  uint i;

  if(pgdir == 0)
80108512:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80108516:	75 0d                	jne    80108525 <freevm+0x19>
    panic("freevm: no pgdir");
80108518:	83 ec 0c             	sub    $0xc,%esp
8010851b:	68 a7 8f 10 80       	push   $0x80108fa7
80108520:	e8 54 80 ff ff       	call   80100579 <panic>
  deallocuvm(pgdir, KERNBASE, 0);
80108525:	83 ec 04             	sub    $0x4,%esp
80108528:	6a 00                	push   $0x0
8010852a:	68 00 00 00 80       	push   $0x80000000
8010852f:	ff 75 08             	push   0x8(%ebp)
80108532:	e8 18 ff ff ff       	call   8010844f <deallocuvm>
80108537:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < NPDENTRIES; i++){
8010853a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80108541:	eb 4f                	jmp    80108592 <freevm+0x86>
    if(pgdir[i] & PTE_P){
80108543:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108546:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
8010854d:	8b 45 08             	mov    0x8(%ebp),%eax
80108550:	01 d0                	add    %edx,%eax
80108552:	8b 00                	mov    (%eax),%eax
80108554:	83 e0 01             	and    $0x1,%eax
80108557:	85 c0                	test   %eax,%eax
80108559:	74 33                	je     8010858e <freevm+0x82>
      char * v = p2v(PTE_ADDR(pgdir[i]));
8010855b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010855e:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80108565:	8b 45 08             	mov    0x8(%ebp),%eax
80108568:	01 d0                	add    %edx,%eax
8010856a:	8b 00                	mov    (%eax),%eax
8010856c:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108571:	83 ec 0c             	sub    $0xc,%esp
80108574:	50                   	push   %eax
80108575:	e8 b4 f4 ff ff       	call   80107a2e <p2v>
8010857a:	83 c4 10             	add    $0x10,%esp
8010857d:	89 45 f0             	mov    %eax,-0x10(%ebp)
      kfree(v);
80108580:	83 ec 0c             	sub    $0xc,%esp
80108583:	ff 75 f0             	push   -0x10(%ebp)
80108586:	e8 51 a6 ff ff       	call   80102bdc <kfree>
8010858b:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < NPDENTRIES; i++){
8010858e:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80108592:	81 7d f4 ff 03 00 00 	cmpl   $0x3ff,-0xc(%ebp)
80108599:	76 a8                	jbe    80108543 <freevm+0x37>
    }
  }
  kfree((char*)pgdir);
8010859b:	83 ec 0c             	sub    $0xc,%esp
8010859e:	ff 75 08             	push   0x8(%ebp)
801085a1:	e8 36 a6 ff ff       	call   80102bdc <kfree>
801085a6:	83 c4 10             	add    $0x10,%esp
}
801085a9:	90                   	nop
801085aa:	c9                   	leave
801085ab:	c3                   	ret

801085ac <clearpteu>:

// Clear PTE_U on a page. Used to create an inaccessible
// page beneath the user stack.
void
clearpteu(pde_t *pgdir, char *uva)
{
801085ac:	55                   	push   %ebp
801085ad:	89 e5                	mov    %esp,%ebp
801085af:	83 ec 18             	sub    $0x18,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
801085b2:	83 ec 04             	sub    $0x4,%esp
801085b5:	6a 00                	push   $0x0
801085b7:	ff 75 0c             	push   0xc(%ebp)
801085ba:	ff 75 08             	push   0x8(%ebp)
801085bd:	e8 ee f8 ff ff       	call   80107eb0 <walkpgdir>
801085c2:	83 c4 10             	add    $0x10,%esp
801085c5:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(pte == 0)
801085c8:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801085cc:	75 0d                	jne    801085db <clearpteu+0x2f>
    panic("clearpteu");
801085ce:	83 ec 0c             	sub    $0xc,%esp
801085d1:	68 b8 8f 10 80       	push   $0x80108fb8
801085d6:	e8 9e 7f ff ff       	call   80100579 <panic>
  *pte &= ~PTE_U;
801085db:	8b 45 f4             	mov    -0xc(%ebp),%eax
801085de:	8b 00                	mov    (%eax),%eax
801085e0:	83 e0 fb             	and    $0xfffffffb,%eax
801085e3:	89 c2                	mov    %eax,%edx
801085e5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801085e8:	89 10                	mov    %edx,(%eax)
}
801085ea:	90                   	nop
801085eb:	c9                   	leave
801085ec:	c3                   	ret

801085ed <copyuvm>:

// Given a parent process's page table, create a copy
// of it for a child.
pde_t*
copyuvm(pde_t *pgdir, uint sz)
{
801085ed:	55                   	push   %ebp
801085ee:	89 e5                	mov    %esp,%ebp
801085f0:	53                   	push   %ebx
801085f1:	83 ec 24             	sub    $0x24,%esp
  pde_t *d;
  pte_t *pte;
  uint pa, i, flags;
  char *mem;

  if((d = setupkvm()) == 0)
801085f4:	e8 e7 f9 ff ff       	call   80107fe0 <setupkvm>
801085f9:	89 45 f0             	mov    %eax,-0x10(%ebp)
801085fc:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80108600:	75 0a                	jne    8010860c <copyuvm+0x1f>
    return 0;
80108602:	b8 00 00 00 00       	mov    $0x0,%eax
80108607:	e9 f6 00 00 00       	jmp    80108702 <copyuvm+0x115>
  for(i = 0; i < sz; i += PGSIZE){
8010860c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80108613:	e9 c2 00 00 00       	jmp    801086da <copyuvm+0xed>
    if((pte = walkpgdir(pgdir, (void *) i, 0)) == 0)
80108618:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010861b:	83 ec 04             	sub    $0x4,%esp
8010861e:	6a 00                	push   $0x0
80108620:	50                   	push   %eax
80108621:	ff 75 08             	push   0x8(%ebp)
80108624:	e8 87 f8 ff ff       	call   80107eb0 <walkpgdir>
80108629:	83 c4 10             	add    $0x10,%esp
8010862c:	89 45 ec             	mov    %eax,-0x14(%ebp)
8010862f:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80108633:	75 0d                	jne    80108642 <copyuvm+0x55>
      panic("copyuvm: pte should exist");
80108635:	83 ec 0c             	sub    $0xc,%esp
80108638:	68 c2 8f 10 80       	push   $0x80108fc2
8010863d:	e8 37 7f ff ff       	call   80100579 <panic>
    if(!(*pte & PTE_P))
80108642:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108645:	8b 00                	mov    (%eax),%eax
80108647:	83 e0 01             	and    $0x1,%eax
8010864a:	85 c0                	test   %eax,%eax
8010864c:	75 0d                	jne    8010865b <copyuvm+0x6e>
      panic("copyuvm: page not present");
8010864e:	83 ec 0c             	sub    $0xc,%esp
80108651:	68 dc 8f 10 80       	push   $0x80108fdc
80108656:	e8 1e 7f ff ff       	call   80100579 <panic>
    pa = PTE_ADDR(*pte);
8010865b:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010865e:	8b 00                	mov    (%eax),%eax
80108660:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108665:	89 45 e8             	mov    %eax,-0x18(%ebp)
    flags = PTE_FLAGS(*pte);
80108668:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010866b:	8b 00                	mov    (%eax),%eax
8010866d:	25 ff 0f 00 00       	and    $0xfff,%eax
80108672:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if((mem = kalloc()) == 0)
80108675:	e8 0c a6 ff ff       	call   80102c86 <kalloc>
8010867a:	89 45 e0             	mov    %eax,-0x20(%ebp)
8010867d:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80108681:	74 68                	je     801086eb <copyuvm+0xfe>
      goto bad;
    memmove(mem, (char*)p2v(pa), PGSIZE);
80108683:	83 ec 0c             	sub    $0xc,%esp
80108686:	ff 75 e8             	push   -0x18(%ebp)
80108689:	e8 a0 f3 ff ff       	call   80107a2e <p2v>
8010868e:	83 c4 10             	add    $0x10,%esp
80108691:	83 ec 04             	sub    $0x4,%esp
80108694:	68 00 10 00 00       	push   $0x1000
80108699:	50                   	push   %eax
8010869a:	ff 75 e0             	push   -0x20(%ebp)
8010869d:	e8 00 cd ff ff       	call   801053a2 <memmove>
801086a2:	83 c4 10             	add    $0x10,%esp
    if(mappages(d, (void*)i, PGSIZE, v2p(mem), flags) < 0)
801086a5:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
801086a8:	83 ec 0c             	sub    $0xc,%esp
801086ab:	ff 75 e0             	push   -0x20(%ebp)
801086ae:	e8 6e f3 ff ff       	call   80107a21 <v2p>
801086b3:	83 c4 10             	add    $0x10,%esp
801086b6:	8b 55 f4             	mov    -0xc(%ebp),%edx
801086b9:	83 ec 0c             	sub    $0xc,%esp
801086bc:	53                   	push   %ebx
801086bd:	50                   	push   %eax
801086be:	68 00 10 00 00       	push   $0x1000
801086c3:	52                   	push   %edx
801086c4:	ff 75 f0             	push   -0x10(%ebp)
801086c7:	e8 84 f8 ff ff       	call   80107f50 <mappages>
801086cc:	83 c4 20             	add    $0x20,%esp
801086cf:	85 c0                	test   %eax,%eax
801086d1:	78 1b                	js     801086ee <copyuvm+0x101>
  for(i = 0; i < sz; i += PGSIZE){
801086d3:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
801086da:	8b 45 f4             	mov    -0xc(%ebp),%eax
801086dd:	3b 45 0c             	cmp    0xc(%ebp),%eax
801086e0:	0f 82 32 ff ff ff    	jb     80108618 <copyuvm+0x2b>
      goto bad;
  }
  return d;
801086e6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801086e9:	eb 17                	jmp    80108702 <copyuvm+0x115>
      goto bad;
801086eb:	90                   	nop
801086ec:	eb 01                	jmp    801086ef <copyuvm+0x102>
      goto bad;
801086ee:	90                   	nop

bad:
  freevm(d);
801086ef:	83 ec 0c             	sub    $0xc,%esp
801086f2:	ff 75 f0             	push   -0x10(%ebp)
801086f5:	e8 12 fe ff ff       	call   8010850c <freevm>
801086fa:	83 c4 10             	add    $0x10,%esp
  return 0;
801086fd:	b8 00 00 00 00       	mov    $0x0,%eax
}
80108702:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80108705:	c9                   	leave
80108706:	c3                   	ret

80108707 <uva2ka>:

//PAGEBREAK!
// Map user virtual address to kernel address.
char*
uva2ka(pde_t *pgdir, char *uva)
{
80108707:	55                   	push   %ebp
80108708:	89 e5                	mov    %esp,%ebp
8010870a:	83 ec 18             	sub    $0x18,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
8010870d:	83 ec 04             	sub    $0x4,%esp
80108710:	6a 00                	push   $0x0
80108712:	ff 75 0c             	push   0xc(%ebp)
80108715:	ff 75 08             	push   0x8(%ebp)
80108718:	e8 93 f7 ff ff       	call   80107eb0 <walkpgdir>
8010871d:	83 c4 10             	add    $0x10,%esp
80108720:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if((*pte & PTE_P) == 0)
80108723:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108726:	8b 00                	mov    (%eax),%eax
80108728:	83 e0 01             	and    $0x1,%eax
8010872b:	85 c0                	test   %eax,%eax
8010872d:	75 07                	jne    80108736 <uva2ka+0x2f>
    return 0;
8010872f:	b8 00 00 00 00       	mov    $0x0,%eax
80108734:	eb 2a                	jmp    80108760 <uva2ka+0x59>
  if((*pte & PTE_U) == 0)
80108736:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108739:	8b 00                	mov    (%eax),%eax
8010873b:	83 e0 04             	and    $0x4,%eax
8010873e:	85 c0                	test   %eax,%eax
80108740:	75 07                	jne    80108749 <uva2ka+0x42>
    return 0;
80108742:	b8 00 00 00 00       	mov    $0x0,%eax
80108747:	eb 17                	jmp    80108760 <uva2ka+0x59>
  return (char*)p2v(PTE_ADDR(*pte));
80108749:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010874c:	8b 00                	mov    (%eax),%eax
8010874e:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108753:	83 ec 0c             	sub    $0xc,%esp
80108756:	50                   	push   %eax
80108757:	e8 d2 f2 ff ff       	call   80107a2e <p2v>
8010875c:	83 c4 10             	add    $0x10,%esp
8010875f:	90                   	nop
}
80108760:	c9                   	leave
80108761:	c3                   	ret

80108762 <copyout>:
// Copy len bytes from p to user address va in page table pgdir.
// Most useful when pgdir is not the current page table.
// uva2ka ensures this only works for PTE_U pages.
int
copyout(pde_t *pgdir, uint va, void *p, uint len)
{
80108762:	55                   	push   %ebp
80108763:	89 e5                	mov    %esp,%ebp
80108765:	83 ec 18             	sub    $0x18,%esp
  char *buf, *pa0;
  uint n, va0;

  buf = (char*)p;
80108768:	8b 45 10             	mov    0x10(%ebp),%eax
8010876b:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(len > 0){
8010876e:	eb 7f                	jmp    801087ef <copyout+0x8d>
    va0 = (uint)PGROUNDDOWN(va);
80108770:	8b 45 0c             	mov    0xc(%ebp),%eax
80108773:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108778:	89 45 ec             	mov    %eax,-0x14(%ebp)
    pa0 = uva2ka(pgdir, (char*)va0);
8010877b:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010877e:	83 ec 08             	sub    $0x8,%esp
80108781:	50                   	push   %eax
80108782:	ff 75 08             	push   0x8(%ebp)
80108785:	e8 7d ff ff ff       	call   80108707 <uva2ka>
8010878a:	83 c4 10             	add    $0x10,%esp
8010878d:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(pa0 == 0)
80108790:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
80108794:	75 07                	jne    8010879d <copyout+0x3b>
      return -1;
80108796:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010879b:	eb 61                	jmp    801087fe <copyout+0x9c>
    n = PGSIZE - (va - va0);
8010879d:	8b 45 ec             	mov    -0x14(%ebp),%eax
801087a0:	2b 45 0c             	sub    0xc(%ebp),%eax
801087a3:	05 00 10 00 00       	add    $0x1000,%eax
801087a8:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(n > len)
801087ab:	8b 45 f0             	mov    -0x10(%ebp),%eax
801087ae:	39 45 14             	cmp    %eax,0x14(%ebp)
801087b1:	73 06                	jae    801087b9 <copyout+0x57>
      n = len;
801087b3:	8b 45 14             	mov    0x14(%ebp),%eax
801087b6:	89 45 f0             	mov    %eax,-0x10(%ebp)
    memmove(pa0 + (va - va0), buf, n);
801087b9:	8b 45 0c             	mov    0xc(%ebp),%eax
801087bc:	2b 45 ec             	sub    -0x14(%ebp),%eax
801087bf:	89 c2                	mov    %eax,%edx
801087c1:	8b 45 e8             	mov    -0x18(%ebp),%eax
801087c4:	01 d0                	add    %edx,%eax
801087c6:	83 ec 04             	sub    $0x4,%esp
801087c9:	ff 75 f0             	push   -0x10(%ebp)
801087cc:	ff 75 f4             	push   -0xc(%ebp)
801087cf:	50                   	push   %eax
801087d0:	e8 cd cb ff ff       	call   801053a2 <memmove>
801087d5:	83 c4 10             	add    $0x10,%esp
    len -= n;
801087d8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801087db:	29 45 14             	sub    %eax,0x14(%ebp)
    buf += n;
801087de:	8b 45 f0             	mov    -0x10(%ebp),%eax
801087e1:	01 45 f4             	add    %eax,-0xc(%ebp)
    va = va0 + PGSIZE;
801087e4:	8b 45 ec             	mov    -0x14(%ebp),%eax
801087e7:	05 00 10 00 00       	add    $0x1000,%eax
801087ec:	89 45 0c             	mov    %eax,0xc(%ebp)
  while(len > 0){
801087ef:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
801087f3:	0f 85 77 ff ff ff    	jne    80108770 <copyout+0xe>
  }
  return 0;
801087f9:	b8 00 00 00 00       	mov    $0x0,%eax
}
801087fe:	c9                   	leave
801087ff:	c3                   	ret
