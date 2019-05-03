
--
-- Constants
--


--
-- Globals
--
DEBUG_MODE = false





--
-- Helper Functions
--

-- Re-seed the Random Number Generation
-- so that if called quickly (sub-seconds)
-- it'll still be random
_incSeed=0
function resetRNG()
    _incSeed = _incSeed + 1
    local seed=os.time() + _incSeed
    math.randomseed(seed)
    --print("Re-seeding RNG="..seed)
end
