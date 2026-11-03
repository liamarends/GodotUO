--!strict
-- Pure rules, also executed by the offline regression suite.
local Rules = {}
export type Profile = {
	version: number,
	uses: { [string]: number },
	receipts: { [string]: boolean },
	activations: { [string]: string },
	attempts: { [string]: boolean },
	pending: { [string]: any },
	progress: number,
	choice: string,
	uniform: number,
	flashlight: number,
	supporter: boolean,
	mementos: number,
	badge: boolean,
}
function Rules.newProfile(): Profile
	return {
		version = 1,
		uses = { SoftSoles = 0, Padding = 0 },
		receipts = {},
		activations = {},
		pending = {},
		attempts = {},
		progress = 0,
		choice = "SoftSoles",
		uniform = 0,
		flashlight = 1,
		supporter = false,
		mementos = 0,
		badge = false,
	}
end
function Rules.isBoost(key: any): boolean
	return key == "SoftSoles" or key == "Padding"
end
function Rules.grantReceipt(
	profile: Profile,
	receiptId: string,
	key: string,
	quantity: number
): boolean
	if profile.receipts[receiptId] then
		return false
	end
	assert(Rules.isBoost(key) and quantity > 0)
	profile.uses[key] += quantity
	profile.receipts[receiptId] = true
	return true
end
function Rules.consume(profile: Profile, roundId: string, key: string): boolean
	if profile.activations[roundId] then
		return profile.activations[roundId] == key
	end
	if not Rules.isBoost(key) or profile.uses[key] < 1 then
		return false
	end
	profile.uses[key] -= 1
	profile.activations[roundId] = key
	return true
end
function Rules.completeAttempt(
	profile: Profile,
	attemptId: string,
	meaningful: boolean,
	interval: number
): boolean
	if not meaningful or profile.attempts[attemptId] then
		return false
	end
	profile.attempts[attemptId] = true
	profile.progress += 1
	if profile.progress >= interval then
		profile.progress -= interval
		profile.uses[profile.choice] += 1
	end
	return true
end
function Rules.meaningful(
	activeSeconds: number,
	carrySeconds: number,
	delivered: number,
	rescued: number,
	minimum: number,
	carryMinimum: number
): boolean
	return activeSeconds >= minimum
		and (carrySeconds >= carryMinimum or delivered > 0 or rescued > 0)
end
function Rules.noise(amount: number, category: string, boost: string?, strength: number): number
	if
		(boost == "SoftSoles" and category == "Footstep")
		or (boost == "Padding" and category == "Furniture")
	then
		return amount * (1 - strength)
	end
	return amount
end
function Rules.awareness(noise: number, hunting: boolean): string
	return if hunting
		then "Awake"
		elseif noise >= 70 then "Searching"
		elseif noise >= 35 then "Stirring"
		else "Asleep"
end
-- Stable shuffled IDs produce specific objectives without making every heavy item mandatory.
function Rules.contract(order: { number }, count: number): { [number]: boolean }
	local chosen: { [number]: boolean } = {}
	for i = 1, math.min(count, #order) do
		chosen[order[i]] = true
	end
	return chosen
end
function Rules.departure(crew: number, aboard: number, votes: number): boolean
	return crew > 0 and aboard == crew and votes == crew
end
function Rules.reward(requiredLoaded: number, optionalLoaded: number, won: boolean): number
	return math.max(0, requiredLoaded) + math.max(0, optionalLoaded) * 2 + (if won then 4 else 0)
end
return Rules
