class_name Rules

# Ace = 1, 2-10 = face value, J/Q/K = 10
static func card_points(card):
	return min(card[0] + 1, 10)

# Returns the melds as lists of indexes, e.g. [[0, 1, 2], [5, 6, 7, 8]]
static func find_melds(hand):
	var melds = []
	var i = 0
	while i < hand.size():
		var length = max(set_length(hand, i), run_length(hand, i))
		if length >= 3:
			melds.append(range(i, i + length))
			i += length
		else:
			i += 1
	return melds

static func set_length(hand, start):
	var length = 1
	while start + length < hand.size() and hand[start + length][0] == hand[start][0]:
		length += 1
	return length

static func run_length(hand, start):
	var length = 1
	while start + length < hand.size():
		var prev = hand[start + length - 1]
		var card = hand[start + length]
		if card[1] != prev[1] or card[0] != prev[0] + 1:
			break
		length += 1
	return length

# Indexes of all cards that are NOT in a meld
static func deadwood_indexes(hand):
	var in_meld = []
	for meld in find_melds(hand):
		in_meld.append_array(meld)
	var result = []
	for i in range(hand.size()):
		if not (i in in_meld):
			result.append(i)
	return result

# The card that gets discarded when knocking: the highest card not in a meld.
# Returns -1 if every card is in a meld.
static func knock_discard_index(hand):
	var best = -1
	for i in deadwood_indexes(hand):
		if best == -1 or card_points(hand[i]) > card_points(hand[best]):
			best = i
	return best

# Deadwood points left after that discard
static func deadwood_after_knock(hand):
	var discard = knock_discard_index(hand)
	var total = 0
	for i in deadwood_indexes(hand):
		if i != discard:
			total += card_points(hand[i])
	return total

# "gin", "knock", or "" if you can't do either
static func knock_type(hand):
	var deadwood = deadwood_after_knock(hand)
	if deadwood == 0:
		return "gin"
	if deadwood <= 10:
		return "knock"
	return ""
	
	# The melds as lists of cards instead of indexes
static func meld_cards(hand):
	var result = []
	for meld in find_melds(hand):
		result.append(meld.map(func(i): return hand[i]))
	return result

# The cards that are not in a meld
static func deadwood_cards(hand):
	return deadwood_indexes(hand).map(func(i): return hand[i])

static func deadwood_points(cards):
	var total = 0
	for card in cards:
		total += card_points(card)
	return total

# For a hand nobody arranged (the AI): try sorting by value and by suit,
# and keep whichever leaves less deadwood
static func best_arrangement(hand):
	var by_value = hand.duplicate()
	by_value.sort_custom(func(a, b): return a[0] < b[0] if a[0] != b[0] else a[1] < b[1])
	var by_suit = hand.duplicate()
	by_suit.sort_custom(func(a, b): return a[1] < b[1] if a[1] != b[1] else a[0] < b[0])
	if deadwood_points(deadwood_cards(by_value)) <= deadwood_points(deadwood_cards(by_suit)):
		return by_value
	return by_suit

# Does this card fit on this meld?
static func fits_meld(card, meld):
	if meld[0][0] == meld[1][0]:          # set: all the same value
		return card[0] == meld[0][0]
	if card[1] != meld[0][1]:             # run: must be the same suit
		return false
	var low = meld[0][0]
	var high = meld[0][0]
	for c in meld:
		low = min(low, c[0])
		high = max(high, c[0])
	return card[0] == low - 1 or card[0] == high + 1

# Lays off as many deadwood cards as possible onto the melds.
# Adds them to the melds and returns the cards that are still deadwood.
static func lay_off(deadwood, melds):
	var remaining = deadwood.duplicate()
	var changed = true
	while changed:
		changed = false
		for card in remaining.duplicate():
			for meld in melds:
				if fits_meld(card, meld):
					meld.append(card)
					remaining.erase(card)
					changed = true
					break
	return remaining
