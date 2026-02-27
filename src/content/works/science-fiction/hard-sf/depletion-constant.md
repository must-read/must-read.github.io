---
title: "Depletion Constant"
slug: "depletion-constant"
genre: "science-fiction"
subgenre: "hard-sf"
authorA: "Ted Chiang"
authorB: "Isaac Asimov"
workX: "Exhalation"
workY: "The Last Question"
wordCount: 4399
readingTimeMinutes: 18
tags: ["hard science fiction", "quantum computing", "entropy", "depletion", "thought experiment"]
rating: 3.7
ratingCount: 9
publishedDate: "2026-02-27"
status: "published"
formulaSummary: "Chiang's crystalline precision meets Asimov's logical patience in a thought experiment about a quantum researcher who discovers computation has a cost denominated in reality itself"
synopsis: "Quantum researcher Lena Garside notices her decoherence measurements drifting and traces the anomaly to a terrifying conclusion: her simulations aren't modeling reality — they're consuming it. The universe has a finite budget, and every computation draws it down."
combination:
  fromAuthorA:
    - "the depletion constant calculation scene — hands-on discovery, crystalline precision"
    - "wonder and grief inseparable in understanding something terminal"
  fromAuthorB:
    - "the Dov Rennick conversation — two scientists eliminating hypotheses, Asimov's dialogue rhythm"
    - "the deep-time gesture in the ending — the question outlasting its askers"
  fromWorkX:
    - "narrator discovers terminal truth through investigation and keeps recording"
    - "the instrument of measurement is the instrument of consumption"
  fromWorkY:
    - "the question recurring across time — insufficient data, the same failure"
    - "whether intelligence can outrun the universe's budget — left genuinely open"
---

Simulation 4,217 was the one that changed things, though Lena did not know it at the time. She was running Herschel-series computations on exotic matter states near absolute zero, and the results were loading on her terminal slowly — three billion probability amplitudes, each one requiring the system to hold its breath. The lab was quiet. It was 11:40 on a Tuesday night, and the only sounds were the low drone of the dilution refrigerator keeping the superconducting qubits at fifteen millikelvin and the occasional click of Lena's pen against the edge of her notebook.

She had been at this for two years. The Herschel series was her design: a sequence of increasingly complex quantum simulations modeling how matter behaves at temperatures where classical physics has nothing useful to say. The qubits in the cryostat below her feet were not atoms or electrons. They were circuits — tiny loops of superconducting aluminum on silicon chips, cooled until they forgot they were metal and began to behave like something more fundamental. At fifteen millikelvin, each qubit existed in a superposition of states so delicate that a stray photon from a cellphone three rooms away could collapse it. The dilution refrigerator existed to keep the world out.

Simulation 4,217 was a decoherence study. She was measuring how long her qubits maintained coherence — how long they held their superpositions before the environment leaked in and forced them to choose. The answer, for the past eight hundred simulations, had been consistent: 247 microseconds, plus or minus three. The number was a known quantity. She had built her error budgets around it. It was the floor on which every subsequent calculation stood.

Tonight the number was 241.

She noted it. Rechecked the cryostat logs. Temperature was nominal — the mixing chamber stage sitting at 14.8 millikelvin, a hair below target, well within tolerance. Magnetic shielding nominal. The mu-metal cage around the cryostat registered no anomalous flux. The vibration isolation platform — three tonnes of concrete on pneumatic springs, the most boring and most important piece of equipment in the building — showed nothing. She ran the simulation again.

239.

The number should not have moved. Decoherence times in a well-shielded system do not drift downward over the course of an hour unless something has changed in the environment, and nothing had changed. Lena had spent two years making sure nothing changed. She had written the shielding protocol herself. She had personally soldered the cryogenic filters on the input lines, twenty-three of them, each one a tiny low-pass circuit designed to keep the thermal noise of room temperature from reaching the qubits. She knew, in the specific way that an experimentalist knows her apparatus, that the system was clean.

The drift was not coming from outside. It was coming from the thing she was measuring.

She marked the data points, closed her notebook, and did not go home for another four hours.

---

By Thursday she had confirmed that the drift was not instrumental. She had swapped the control electronics, recalibrated the readout resonators, even moved the measurement window to a different section of the qubit array. The decoherence times continued their quiet decline. 237. 234. Each number a small concession the system was making to something Lena could not identify. It was as though the ruler she used to measure was shrinking — not the equipment, not the qubits, but the thing behind both. The background itself.

She brought it to Dov Rennick on Friday morning. Dov was the facility's resident theorist, which meant he occupied a windowless office on the third floor, surrounded by whiteboards covered in notation that looked, to Lena, like the aftermath of a controlled detonation in a mathematics department. He was fifty-three, balding in a way that suggested he had never once thought about it, and he had the theorist's habit of listening to experimental results with his eyes closed, as though the data were music and he was checking for off notes.

"How many simulations total?" he asked, eyes still closed.

"Four thousand two hundred and thirty-one, as of this morning."

"And the drift is monotonic?"

"Strictly. No recovery, no plateau. The decoherence times are falling by about one and a half microseconds per hundred simulations."

"That's not thermal."

"No."

"It's not magnetic."

"No."

"And the decline is proportional to simulation count, not to elapsed time?"

Lena paused. She had not framed it that way, but he was right. The drop correlated with the number of simulations she ran, not with the hours that passed between them. On days she ran fifty simulations, the decline was steeper. On days she ran ten, it was shallower. The clock was not the clock. The simulations were the clock.

"That's what the data says," she said.

Dov opened his eyes. He was quiet for a moment, tapping the marker against his palm.

"Cumulative radiation damage to the substrate," he said. "Each simulation deposits a tiny dose. The qubits degrade."

"I swapped the chip array after simulation four thousand. Fresh substrate. The drift continued from where it left off."

He stopped tapping. "Continued exactly?"

"Within error bars. As if the new chip remembered what the old one had done."

He stared at the whiteboard. Lena could see him discarding something — not the hypothesis itself, but the comfort of it. Equipment damage was a solvable problem. What she was describing was not an equipment problem.

"Then you're not measuring a change in your equipment. You're measuring a change in whatever your equipment is measuring."

"The substrate."

"The substrate." He picked up the marker, turned to a whiteboard that had a small clear patch in the lower right corner, and drew a horizontal line. "Suppose the number of available quantum states your system can access is finite. Not infinite, the way we usually model it. Finite. A pool. And every time you run a simulation — every time you collapse superpositions, force measurements, entangle qubits with your readout apparatus — you're drawing from that pool. Spending states that don't come back."

"That's not — " Lena stopped. She had been about to say *that's not how quantum mechanics works*, and it wasn't, not in any formalism she had been taught. But the data was sitting in her notebook, monotonic and unbothered by what the formalisms said.

"I know it's not how anything works," Dov said. "I'm asking you to consider what happens if it is."

"Then the decoherence times are falling because there are fewer states to cohere in. The pool is shallower, so the qubits can't hold their superpositions as long."

"Right. And the more you simulate — "

"The shallower it gets."

Dov drew a descending line on the whiteboard, a curve that began with a nearly flat slope and steepened as it approached the axis. "It's like a bank account. Every computation is a withdrawal. The balance sheet doesn't distinguish between a simulation that models protein folding and a simulation that models exotic matter at millikelvin. A state is a state. Used is used."

He was half-smiling, the way he did when he was running a thought experiment he did not yet believe. But the smile was doing something different today. It was trying to be a joke and failing.

"There's a term for this," he said, "in game theory. A self-confirming equilibrium. Players whose predictions are correct for every branch that actually gets played, but who may be completely wrong about branches never reached. The equilibrium holds because the beliefs are never tested." He tapped the whiteboard. "Your simulations have been in a self-confirming equilibrium with reality. Your models predicted decoherence at 247 microseconds, and for four thousand runs that was correct. But you've been drawing from the pool the entire time. The prediction was accurate because you were spending the states you were modeling. The model matched what was left because the model was shaping what was left."

Lena started to say something and stopped. She was thinking about what it meant for a model to consume its own subject matter — not metaphorically, not as an analogy, but as a physical process. The model worked because it was replacing reality with itself, and the replacement was close enough that no one noticed the original shrinking.

"Yes," Dov said, though she hadn't finished the thought aloud.

She looked at the descending curve on the whiteboard and thought about the four thousand simulations she had already run, each one a small subtraction from a total she had not known existed, each one confirming a number that was correct right up until it wasn't.

"Dov," she said. "If this is real, it's not just my lab."

"No."

"Every quantum computer in the world is drawing from the same pool."

"Every quantum computer. Every quantum process. Every photon that hits a detector. Every electron that's measured. The universe is running a budget, Lena, and everything that happens is an expense."

"But we're running at a scale nobody else is running. The Herschel series — "

"Is the most computationally expensive quantum program on the planet. By a factor of about four thousand." He put the marker down. "You're not the only one spending. But you're the biggest spender in the room."

Lena stared at the whiteboard. The descending curve looked wrong to her — not mathematically wrong, but wrong in the way a crack in a load-bearing wall looks wrong before you understand the engineering. Something in her resisted the shape. She had been trained to treat quantum states as inexhaustible, and the training ran deeper than the data.

"What's the total budget?" she asked.

"Unknown. Possibly unknowable, from inside the system. You can measure the rate of withdrawal. You can't measure the balance, because measuring the balance is itself a withdrawal."

"Then how do I know it's finite?"

"Because the decoherence times are dropping. An infinite pool doesn't get shallower. Something is decreasing, Lena. The only question is how much was there to begin with."

---

She spent the weekend doing the mathematics. Not in the lab — at her kitchen table, with a legal pad and a mechanical pencil her father had given her when she finished her doctorate. The pencil was a Pentel P205, nothing special, but her father had used it for forty years at the machine shop where he'd worked, and the barrel was worn smooth in a way that no new pencil would ever be.

The calculation was not difficult. That was the thing she would remember later — not the result, but the simplicity of arriving at it. If the decline in decoherence times was proportional to simulation count, and if the decline rate was consistent across different qubit architectures (she checked; Dov had sent her data from two other labs that had reported similar anomalies and attributed them to equipment aging), then the total number of collapsed states could be estimated from the slope of the decline and the known properties of the simulations.

She derived it on a single sheet of legal paper. The ratio of consumed quantum states to remaining quantum states, per qubit-operation, across the observable volume of the universe.

She called it the depletion constant. It was a small number. Absurdly small by human standards — on the order of 10^-124 per qubit-operation. The universe's budget was vast. Her four thousand simulations had spent a portion of it that would take scientific notation to describe, a fraction so small that writing it in decimal would require more zeros than atoms in the lab.

But the budget was finite. And the rate of global quantum computation was doubling every fourteen months.

She sat at her kitchen table and looked at the number on the legal pad and understood two things at once. The first was that the depletion constant was real — not a model, not a projection, but a property of the universe as fundamental as the speed of light or the gravitational constant. The universe contained a finite number of quantum states. Every measurement consumed some. The consumption was irreversible.

The second thing she understood was worse. To confirm the depletion constant to the standard required for publication — to establish it as a physical constant rather than an anomaly in one researcher's data — she would need to run a series of verification simulations designed to measure the rate of depletion at different computational scales. Large simulations and small ones. Dense qubit arrays and sparse ones. A systematic survey of the relationship between computational complexity and state consumption.

Each of those simulations would consume states.

The act of measuring the depletion constant would itself deplete the budget. The instrument of measurement was the instrument of consumption. She could not study the problem without accelerating it, any more than she could read a book by candlelight without burning the candle.

She put the pencil down and looked at the kitchen. It was a small kitchen. The dishes were done. The counters were clean. Through the window she could see the parking lot of her apartment complex, half-empty on a Saturday, and beyond it the strip of desert that edged the facility's campus, dry and pale in the winter light. She had chosen this apartment for the view of the desert, which was not beautiful but was large, and there were days when largeness was what she needed.

Today she needed it and it was not enough.

---

She thought about her father. Not deliberately — the thought arrived the way his thoughts about machining had arrived, unbidden, while his hands were doing something else. He had been a machinist for forty-one years, at a shop in Dayton that made precision parts for aerospace companies. When he retired, he built model trains. Not kits. Scratch-built models, fabricated from brass stock and solder and patience, each one a scaled replica of a real locomotive that had once carried passengers on tracks that no longer existed.

His specialty was the LSWR T6 class. Ten express passenger locomotives, 4-4-0 wheel arrangement, designed by William Adams for the London and South Western Railway and built at Nine Elms in 1885 and 1886. Ten of them. Each one hand-built at the works, each one given a name and number, each one slightly different in the ways that hand-built machines are always slightly different — a rivet line that wanders half a millimeter, a boiler cladding that sits a fraction proud of the frame. Her father had built models of all ten. They sat in a glass case in the house in Dayton where she had grown up, and after he died eighteen months ago she had brought the case to her apartment in New Mexico and set it on the shelf above her desk, and she had not opened it because she did not want to touch them and she did not want to not touch them and there was no third option.

He had told her once, while she was home for Christmas and watching him solder a running board to locomotive number 655, that the thing about the T6 class was that there were only ten. Not a production run. Not a fleet. Ten machines, each built because someone decided it was worth building, each maintained for decades by men who knew its specific creaks and temperaments. "They named them," he said. "Not like we name cars. Like you'd name a horse. Because each one was going to cost you if it broke, and you couldn't just order another one."

She had not understood him at the time, or rather, she had understood him the way you understand a parent's hobbies — with affection and mild incomprehension, the way you understand that someone loves a thing without understanding the thing itself.

She looked at the glass case above her desk. Ten tiny locomotives behind glass, each one containing hundreds of hours of a dead man's attention. Number 655 had a running board he had soldered three times before he was satisfied. She could still see the faint discoloration where the first two attempts had been.

She picked up the pencil and went back to the math.

---

On Monday she told Dov what she wanted to do.

"I need to run the verification suite. Twelve simulations at graduated scales. It'll take about a week."

Dov was standing at his whiteboard, which now had Lena's depletion constant written on it in red marker, circled twice. He did not turn around.

"You know what that costs."

"I've calculated it. The twelve verification runs will consume approximately 3.7 times 10^-121 of the remaining state budget. At current global computation rates, that's equivalent to about nine hours of worldwide quantum activity."

"Nine hours of everyone's budget, spent in a week, by one lab."

"Yes."

"And if you don't run them?"

"Then I publish a theoretical paper based on the data I have. The decoherence drift, the correlation with simulation count, the derivation of the constant. A theoretical paper with one lab's data and no controlled verification." She paused. "It'll be dismissed. You know it'll be dismissed. Not because the physics is wrong but because the claim is extraordinary and the evidence is ordinary. One researcher's decoherence measurements and a derivation on a legal pad."

"The legal pad is good work."

"It's good work that looks like a mistake. I need the verification suite to make it look like a discovery."

Dov turned from the whiteboard. His expression was not the half-smile from Friday. It was something flatter, more considered — the expression of a man who has done the math himself and arrived at the same place.

"There's an argument," he said, "for not running them."

"I know the argument."

"The argument is that every verification simulation you run depletes states that can never be recovered. That the knowledge you gain is purchased with a currency you can't earn back. That the universe doesn't owe you confirmation."

"The universe doesn't owe anyone anything. But I owe the data the best interpretation I can give it. And other people — other labs, other decades — are going to hit this anomaly eventually, Dov. They'll see the decoherence drift, and they'll spend months diagnosing it as equipment error, and they'll run their own verification suites, their own graduated simulations. The states get spent either way. The only question is whether they get spent in ignorance or in the presence of a paper that tells the next researcher what the drift means."

"You're arguing that spending the budget on understanding is cheaper than spending it on confusion."

"I'm arguing that someone is going to spend it. The budget doesn't care who. If I can establish the constant now, with twelve simulations, I save whoever comes after me from running twelve hundred."

Dov was quiet for a long time. Through the wall, Lena could hear the faint mechanical heartbeat of the cryostat, steady and indifferent.

"Run them," he said.

---

She ran them.

Not all at once. Over seven days, one simulation in the morning and one in the evening, each at a different computational scale. She varied the qubit count — fifty, two hundred, a thousand — and the gate depth, from shallow circuits that barely taxed the system to the deep entangling sequences that were the Herschel series' signature. She varied the number of measurements per cycle. She ran one simulation using only single-qubit gates, no entanglement at all, as a control. The decoherence drift in that run was present but shallow, almost flat, like the difference between a dripping tap and an open faucet. Entanglement was expensive. The more qubits she tangled together, the more states the operation consumed. This made a kind of terrible sense: entanglement was precisely the operation that forced the universe to correlate states across distances, to commit to relationships between particles that could not be uncommitted. Each entangling gate was a small, permanent decision imposed on a system that had fewer decisions left to make.

She recorded everything — not just the results but the environmental conditions, the timing, the sequence, the specific configuration of each run. The decoherence times continued their descent. Each simulation produced results that confirmed the constant and, in confirming it, contributed infinitesimally to the process it described.

During the fourth simulation she caught herself reaching for analogies and stopped. A candle consumes wax but produces light. Erosion removes rock but deposits sediment. What her simulations consumed did not transform into something else. A quantum state, once collapsed, was not energy or information or anything recoverable. It was gone in a way she did not have a metaphor for, and she distrusted the impulse to invent one.

The data came in clean. The depletion rate scaled linearly with gate depth and quadratically with qubit count, exactly as her derivation predicted. The constant held across every scale she tested. 10^-124 per qubit-operation, plus or minus a margin so small it might as well have been zero.

On the seventh day she plotted the full dataset and sat with it for an hour. The plot was a straight line, which meant the depletion was constant-rate under current conditions — no acceleration, no deceleration. The universe was spending at a fixed rate per operation, and the rate would remain fixed until the total budget dropped low enough to change the physics. That threshold was very far away. At current computation rates, including her lab and every other quantum system on the planet, the budget would last longer than the projected lifetime of the stars. Not forever. But long enough that no human civilization would witness its exhaustion.

This should have been a comfort. It was not. Because the computation rates were not staying current. They were doubling every fourteen months. And the simulations were getting more complex, not less. And the number of labs was growing. And none of them knew there was a budget.

She wrote the paper in three days. Title: "Evidence for a Finite Quantum State Budget: Measurement of a Universal Depletion Constant." Fourteen pages, single-spaced, plus supplementary data. She included the derivation, the verification data, the full methodology. She named the constant — lowercase delta with a subscript *d*. Greek letters are how physics makes a number official. She wanted anyone reading the paper to understand that this was not a conjecture but a measurement, as concrete as the charge of an electron or the mass of a proton. She credited Dov. She included a section on implications, written in the restrained language of a scientist who has understood something vast and is trying to say it without shouting.

And then she added a final section. It was not standard. It would not survive peer review in its current form, and she knew that, and she wrote it anyway.

The section asked a question. Not whether the depletion could be reversed — that was thermodynamics, and the answer was almost certainly no. The section asked whether intelligence and depletion were the same process viewed from different angles. Whether the universe's capacity for complexity and its capacity for exhaustion drew from the same account.

She did not answer the question. She was not sure it was the kind of question that could be answered from inside the system it described.

---

The paper went to the facility's internal review board, which sent it to three external physicists, who returned it in eleven days with comments that ranged from hostile to shaken. One reviewer wrote a single line: *If this is correct, it changes the meaning of computation.* Another wrote four pages of objections, each one technically precise, each one addressed by data Lena had already collected. The third reviewer asked for the raw decoherence logs, which Lena sent. Two days later the third reviewer sent a message asking if she had checked her cryostat seals. Lena sent photos. The reviewer did not write back for a week, and when he did, the message said: *I am running my own verification. I expect to reach the same result. I want to be wrong.*

Lena read that message at her kitchen table, in the evening, with the glass case of model locomotives visible at the edge of her sight. She thought about the reviewer's lab, wherever it was — Princeton, Zurich, Sydney — running its own verification simulations at that moment, consuming its own small portion of the budget to confirm that the budget existed. She thought about the labs that would follow. The graduate students who would design dissertation projects around the constant, each project a tiny withdrawal from a total that their dissertations would help quantify. Generations of physicists spending states to understand the rate at which states were being spent.

She did not feel grief about this, exactly. What she felt was more specific: a loss of mathematical comfort. The infinite Hilbert space, the bottomless well of quantum states — these had been fictions she relied on without knowing she relied on them, the way you rely on the floor being solid. The floor was still solid. It was just thinner than she'd thought, and underneath it there was something she didn't have a name for.

She saved the reviewer's message. She filed the paper. She ate dinner. She went to bed and did not sleep for a long time, but that was not new. She had not slept well since her father died. Before that, other reasons. Sleeplessness was old enough that she no longer diagnosed it.

In the morning she went to the lab and began designing the next Herschel simulation. The data was good. The methodology was sound. The next simulation in the series would extend the measurement to a regime no one had explored.

She did not think about the question in her final section. She thought about gate depths and qubit configurations and the specific order of operations that would give her the cleanest signal. Somewhere, in a lab she would never visit, the other reviewer's verification was running.

She entered the parameters for simulation 4,244 and pressed run. The dilution refrigerator hummed. The qubits dropped into their superpositions, delicate and temporary, and the system began its work — measurement and subtraction, the same operation, conducted in a building at the edge of a desert by a woman who had recently learned the price of the tool she was using and had decided to use it anyway.
