package main

import "core:fmt"

Comb_Or :: [dynamic]Comb_And
Comb_And :: [12]Comb_Item
Comb_Item :: bit_set[enum {
	Used,
	True,
};u8]

optimize_controls :: proc(ctrls: []Controls) -> (bits: [20]Comb_Or) {
	for ctrl, i in ctrls {
		if ctrl.flags & 1 != 0 {
			continue
		}

		ctrl_num := u32(ctrl)
		for &b, b_num in bits {
			if ctrl_num & 1 != 0 {
				append(&b, comb_from(i))
			}
			ctrl_num >>= 1
		}
	}

	for &b, i in bits {
		fmt.printfln("optimizing %d", i)
		optimize_comb_or(&b)
	}

	return
}

optimize_comb_or :: proc(ors: ^Comb_Or) {
	for {
		changed := false

		base := 0
		for base < len(ors) {
			off := 1
			for base + off < len(ors) {
				new_v, ok := opt_pair(ors[base][:], ors[base + off][:])
				if !ok {
					off += 1
					continue
				}

				ors[0] = new_v
				unordered_remove(ors, base + off)
				changed = true
			}

			base += 1
		}

		if !changed {
			break
		}

		fmt.printfln("again %d", len(ors))
	}
}

opt_pair :: #force_inline proc(a: []Comb_Item, b: []Comb_Item) -> (out: Comb_And, ok: bool) {
	copy(out[:], a)

	for v, i in soa_zip(a = a, b = b) {
		if .Used not_in v.a && .Used not_in v.b {
			continue
		}

		if .True in v.a == .True in v.b {
			continue
		}

		if ok {
			return out, false
		}

		out[i] = {}
		ok = true
	}
	return

}

comb_from :: proc(n: int) -> (out: Comb_And) {
	n := n
	for &it in out {
		it |= {.Used}
		if n & 1 != 0 {
			it |= {.True}
		}
		n >>= 1
	}
	return
}
