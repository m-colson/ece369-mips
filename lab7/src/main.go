package main

import "math"

type Dims struct {
	FrameHeight, FrameWidth   int
	WindowHeight, WindowWidth int
}

type Window []int
type Frame []int

func main() {
	vbsme(&Dims{FrameHeight: 8, FrameWidth: 8, WindowHeight: 1, WindowWidth: 1}, make(Frame, 1024), make(Window, 1024))
}

func vbsme(dims *Dims, block Frame, wind Window) (bestX, bestY int) {
	xLimit := dims.FrameWidth - dims.WindowWidth
	yLimit := dims.FrameHeight - dims.WindowHeight

	bestX = 0
	bestY = 0

	x := 0
	y := 0
	state := 0
	bestSad := math.MaxInt32
	for {
		if x <= xLimit && y <= yLimit {
			sad := 0

			j := 0
			for {
				if j >= dims.WindowHeight {
					break
				}

				i := 0
				for {
					if i >= dims.WindowWidth {
						break
					}

					bv := block[(y+j)*dims.FrameWidth+x+i]
					wv := wind[j*dims.WindowWidth+i]

					diff := bv - wv
					if diff < 0 {
						diff = -diff
					}

					sad = sad + diff

					i = i + 1
				}

				j = j + 1
			}

			if sad < bestSad {
				bestX = x
				bestY = y
				bestSad = sad
			}
		}

		if x >= xLimit && y >= yLimit {
			break
		}

		switch state {
		case 0:
			x = x + 1
			state = 1
		case 1:
			x = x - 1
			y = y + 1
			if x <= 0 || y >= yLimit {
				state = 2
			}
		case 2:
			y = y + 1
			state = 3
		case 3:
			x = x + 1
			y = y - 1
			if x >= xLimit || y <= 0 {
				state = 0
			}
		}
	}

	return
}
