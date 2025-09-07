---
title: 拜占庭将军 - 论文翻译
date: 2022-07-11
tags: [Distributed]
categories: Distributed
toc: true
---

# INTRODUCTION

A reliable computer system must be able to cope with the failure of one or more of its components. A failed component may exhibit a type of behavior that is often overlooked--namely, sending conflicting information to different parts of the system. The problem of coping with this type of failure is expressed abstractly as the Byzantine Generals Problem. We devote the major part of the paper to a discussion of this abstract problem and conclude by indicating how our solutions can be used in implementing a reliable computer system. We imagine that several divisions of the Byzantine army are camped outside an enemy city, each division commanded by its own general. The generals can communicate with one another only by messenger. After observing the enemy, they must decide upon a common plan of action. However, some of the generals may be traitors, trying to prevent the loyal generals from reaching agreement. The generals must have an algorithm to guarantee that   

一个可靠的计算机系统必须能够应付它的一个或多个部件的故障。一个失败的组件可能会表现出一种经常被忽略的行为——即，向系统的不同部分发送冲突的信息。应对这种类型的失败的问题被抽象地表达为拜占庭将军问题。我们将论文的主要部分用于讨论这一抽象问题，并通过表明我们的解决方案可以用于实现一个可靠的计算机系统。我们想象一下，拜占庭军队的几个师在敌人的城市外扎营，每个师由自己的将军指挥。将军们只能通过信使相互联系。在观察敌人之后，他们必须决定一个共同的行动计划。然而，有些将军可能是叛徒，试图阻止忠诚的将军达成协议。将军们肯定有算法来保证:    

A. All loyal generals decide upon the same plan of action.
The loyal generals will all do what the algorithm says they should, but the traitors may do anything they wish. The algorithm must guarantee condition A regardless of what the traitors do. The loyal generals should not only reach agreement, but should agree upon a reasonable plan. We therefore also want to insure that.  

## A. 所有忠诚的将军都决定相同的行动计划。   

忠诚的将军都会按照算法的要求行事，而叛徒则可以随心所欲。算法必须保证不管叛徒做了什么, 所有忠诚的将军都决定相同的行动计划。忠诚的将军们不仅要达成一致，而且要商定一个合理的计划。因此，我们也希望确保这一点   

## B. A small number of traitors cannot cause the loyal generals to adopt a bad plan.   

B. 少数叛徒不能使忠诚的将军采取错误的计划。   


Condition B is hard to formalize, since it requires saying precisely what a bad plan is, and we do not attempt to do so. Instead, we consider how the generals reach a decision. Each general observes the enemy and communicates his observations to the others. Let v(i) be the information communicated by the ith general. Each general uses some method for combining the values v (1) ..... v(n) into a single plan of action, where n is the number of generals. Condition A is achieved by having all generals use the same method for combining the information, and Condition B is achieved by using a robust method. For example, if the only decision to be made is whether to attack or retreat, then v(i) con be General i's opinion of which option is best, and the final decision can be based upon a majority vote among them. A small number of traitors can affect the decision only if the loyal generals were almost equally divided between the two possibilities, in which case neither decision could be called bad. While this approach may not be the only way to satisfy conditions A and B, it is the only one we know of. It assumes a method by which the generals communicate their values v (i) to one another. The obvious method is for the ith general to send v (i) by messenger to each other general. However, this does not work, because satisfying condition A requires that every loyal general obtain the same values v(1) ..... v(n), and a traitorous general may send different values to different generals. For condition A to be satisfied, the following must be true:   

条件B很难去具象化，因为它需要准确地说清楚错误的计划是什么，我们不打算去具体描述它。相反，我们考虑将军们如何达成这个共识。每个将军观察敌人并且和其他人沟通他的观察结果。设v(i)是将军i所传达的信息，每个将军使用一些方法来让v(1)~v(n)形成一个具体的行动。条件A是通过让所有的将军使用相同的方法来组合信息来实现的，条件B是通过使用鲁棒的方法来实现的。比如，如果决策是去进攻或者撤退，v(i)是将军i认为最佳的选项，最终结论可以通过他们的多数投票决定。只有当忠诚的将领几乎平分两种可能性时，少数叛徒才能影响决策，在这种情况下，任何一个决策都不能被称为错误的决定。虽然这种方法可能不是满足条件A和B的唯一方法，但它是我们所知道的唯一方法。它假定了一种方法，通过这种方法，将军们互相传达他们的价值观v (i)。最明显的方法是第i个将军通过信使发送v (i)给其他将军。然而，这是行不通的，因为满足条件A要求每个忠诚的将军都获得相同的值v(1) .....V (n)，一个叛变的将军可能会向不同的将军传达不同的价值观。要满足条件A，必须满足以下条件:  

### 1) Every loyal general must obtain the same information v (1) .... , v (n).  
  
Condition 1 implies that a general cannot necessarily use a value of v(i) obtained directly from the ith general, since a traitorous ith general may send different values to different generals. This means that unless we are careful, in meeting condition 1 we might introduce the possibility that the generals use a value of v (i) different from the one sent by the ith general--even though the ith general is loyal. We must not allow this to happen if condition B is to be met. For example, we cannot permit a few traitors to cause the loya generals to base their decision upon the values "retreat",..., "retreat" if every loyal general sent the value "attack". We therefore have the following requirement for each i: 
  
1) 每个忠诚的将军必须获得相同的信息v (1) ....， v(n)。
  
条件1表明，将军不能使用直接从第i个将军处获得的v(i)的值，因为叛变的第i个将军可能会向不同的将军发送不同的值。这意味着，除非我们很小心，在满足条件1时，我们可能会引入这样一种可能性:将军使用的v (i)值与第i个将军发送的值不同——即使第i个将军是忠诚的。如果要满足条件B，我们决不能允许这种情况发生。例如，我们不能允许少数叛徒使忠诚将军们根据 “retreat”....."retreat" 的价值观作出决定，如果每一个忠诚的将军都发出“进攻”的指令。因此，我们对每个i有以下要求:

### 2) If the ith general is loyal, then the value that he sends must be used by every loyal general as the value of v (i).  
  
2) 如果第i个将军是忠诚的，那么他发送的值必须被每个忠诚的将军用作v (i)的值。
  
We can rewrite condition I as the condition that for every i (whether or not the ith general is loyal):
  
1'. Any two loyal generals use the same value of v(i).  
Conditions 1' and 2 are both conditions on the single value sent by the ith general. We can therefore restrict our consideration to the problem of how a single general sends his value to the others. We phrase this in terms of a commanding general sending an order to his lieutenants, obtaining the following problem. Byzantine Generals Problem. A commanding general must send an order to his n - 1 lieutenant generals such that 
  
条件1'和2都是第i个将军发送的单个值的条件。因此，我们可以把我们的考虑限制在一个将军如何把他的值传递给其他人的问题上。我们用一个将军向他的副手们发出命令的方式来表述这个问题，得到了下面的问题。拜占庭将军的问题。一位指挥官必须向他的n - 1名中将发出这样的命令:
  
#### IC1. All loyal lieutenants obey the same order.
#### IC2. If the commanding general is loyal, then every loyal lieutenant obeys the order he sends. 

IC1。所有忠诚的中尉都服从同一条命令。
IC2。如果指挥官是忠诚的，那么每个忠诚的中尉都会服从他的命令。
  
Conditions IC1 and IC2 are called the interactive consistency conditions. Note that if the commander is loyal, then IC1 follows from IC2. However, the commander need not be loyal. To solve our original problem, the ith general sends his value of v(i) by using a solution to the Byzantine Generals Problem to send the order "use v (i) as my value", with the other generals acting as the lieutenants. 
  
IC1和IC2称为交互一致性条件。注意，如果指挥官是忠诚的，IC1包含于IC2。但是指挥官不一定是忠诚的。为了解决我们最初的问题，第i个将军发出他的值v(i)，通过使用拜占庭将军问题的一个解决方案，发送命令“使用v(i)作为我的值”，其他将军充当中尉。
  
## 2. IMPOSSIBILITY RESULTS
  
2. 不可能的结果

The Byzantine Generals Problem seems deceptively simple. Its difficulty is indicated by the surprising fact that if the generals can send only oral messages, then no solution will work unless more than two-thirds of the generals are loyal. In particular, with only three generals, no solution can work in the presence of a single traitor. An oral message is one whose contents are completely under the control of the sender, so a traitorous sender can transmit any possible message. Such a message corresponds to the type of message that computers normally send to one another. In Section 4 we consider signed, written messages, for which this is not true. 
  
We now show that with oral messages no solution for three generals can handle a single traitor. For simplicity, we consider the case in which the only possible decisions are "attack" or "retreat". Let us first examine the scenario pictured in Figure 1 in which the commander is loyal and sends an "attack" order, but Lieutenant 2 is a traitor and reports to Lieutenant 1 that he received a "retreat" order. For IC2 to be satisfied, Lieutenant 1 must obey the order to attack. 
  
Now consider another scenario, shown in Figure 2, in which the commander is a traitor and sends an "attack" order to Lieutenant 1 and a "retreat" order to Lieutenant 2. Lieutenant 1 does not know who the traitor is, and he cannot tell what message the commander actually sent to Lieutenant 2. Hence, the scenarios in these two pictures appear exactly the same to Lieutenant 1. If the traitor lies consistently, then there is no way for Lieutenant 1 to distinguish between these two situations, so he must obey the "attack" order in both of them. Hence, whenever Lieutenant 1 receives an "attack" order from the commander, he must obey it. 

拜占庭将军问题看似简单。他的困难点在于，如果将军们只能口头传递信息，那么除非三分之二的将军是忠诚的，否则不会有解决方案。特别是，只有三个将军，任何解决方案在一个叛徒面前都无法奏效。口头信息的内容完全在发送者的控制之下，所以一个叛国的发送者可以传递任何可能的信息。这种消息对应于计算机通常相互发送的消息类型。在第4节中，我们考虑了签名的书面消息, 对于这样的消息，这是做不到的（指的是签名的书面消息，不会让叛徒随意传递消息）。
  
我们现在证明，通过口头消息，三个将军的解决方案对付不了一个叛徒。让我们先来看看图1所示的场景:指挥官很忠诚，发出了“攻击”命令，但中尉2是叛徒，他向中尉1报告他收到了“撤退”命令。为了使IC2满意，中尉1必须服从攻击命令。
  
现在考虑另一种场景，如图2所示，其中指挥官是叛徒，向中尉1发送“攻击”命令，向中尉2发送“撤退”命令。中尉1不知道叛徒是谁，他也不知道指挥官到底给中尉2发了什么信息。因此，在中尉1看来，这两幅图中的场景是完全相同的。如果叛徒一直说谎，那么中尉1就没有办法区分这两种情况，所以他必须在两种情况下都服从“攻击”命令。因此，每当中尉收到指挥官的“攻击”命令时，他必须遵守。
  
However, a similar argument shows that if Lieutenant 2 receives a "retreat" order from the commander then he must obey it even if Lieutenant 1 tells him that the commander said "attack". Therefore, in the scenario of Figure 2, Lieutenant 2 must obey the "retreat" order while Lieutenant 1 obeys the "attack" order, thereby violating condition IC1. Hence, no solution exists for three generals that works in the presence of a single traitor. 
    
This argument may appear convincing, but we strongly advise the reader to be very suspicious of such nonrigorous reasoning. Although this result is indeed correct, we have seen equally plausible "proofs" of invalid results. We know of no area in computer science or mathematics in which informal reasoning is more likely to lead to errors than in the study of this type of algorithm. For a rigorous proof of the impossibility of a three-general solution that can handle a single traitor, we refer the reader to [3].
  
然而，一个类似的论点表明，如果中尉2收到指挥官的“撤退”命令，那么他必须遵守，即使中尉1告诉他指挥官说的是“攻击”。因此，在图2场景中，中尉2必须服从“撤退”命令，而中尉1必须服从“进攻”命令，因此违反了条件IC1。因此，在一个叛徒在场的情况下，三个将军是不存在解决方案的。

Using this result, we can show that no solution with fewer than 3m + 1 generals can cope with m traitors. The proof is by contradiction--we assume such a  solution for a group of 3m or fewer and use it to construct a three-general solution  to the Byzantine Generals Problem that works with one traitor, which we know  to be impossible. To avoid confusion between the two algorithms, we call the  generals of the assumed solution Albanian generals, and those of the constructed  solution Byzantine generals. Thus, starting from an algorithm that allows 3m or  fewer Albanian generals to cope with m traitors, we construct a solution that  allows three Byzantine generals to handle a single traitor.  
  
The three-general solution is obtained by having each of the Byzantine generals  simulate approximately one-third of the Albanian generals, so that each Byzantine general is simulating at most m Albanian generals. The Byzantine commander simulates the Albanian commander plus at most m - 1 Albanian  lieutenants, and each of the two Byzantine lieutenants simulates at most m  Albanian lieutenants. Since only one Byzantine general can be a traitor, and he  simulates at most m Albanians, at most m of the Albanian generals are traitors.  Hence, the assumed solution guarantees that IC1 and IC2 hold for the Albanian  generals. By IC1, all the Albanian lieutenants being simulated by a loyal Byzantine lieutenant obey the same order, which is the order he is to obey. It is easy to  check that conditions IC1 and IC2 of the Albanian generals solution imply the  corresponding conditions for the Byzantine generals, so we have constructed the  required impossible solution. 
  
利用这个结果，我们可以证明，少于3m + 1个将军的解无法应对m个叛徒。证明方法是矛盾的——我们假设这样的解对于3m或更少的一群人来说，并使用它来构建一个适用于三个将军，一个叛徒的拜占庭将军问题，我们知道这是不可能的。为了避免两种算法之间的混淆，我们称假设解的将军为阿尔巴尼亚将军，而称构造解的将军为拜占庭将军。因此，从一个允许3m或更少的阿尔巴尼亚将军对付m个叛徒的算法开始，我们构建了一个允许3个拜占庭将军对付一个叛徒的解决方案。
  
三个将军的解决方案是由每个拜占庭将军模拟大约三分之一的阿尔巴尼亚将军得到的，这样每个拜占庭将军最多模拟m个阿尔巴尼亚将军。拜占庭指挥官模拟阿尔巴尼亚指挥官加上最多m - 1个阿尔巴尼亚中尉，两个拜占庭中尉分别模拟最多m个阿尔巴尼亚中尉。因为只有一个拜占庭将军可以是叛徒，而且他最多模拟了m个阿尔巴尼亚人，所以最多m个阿尔巴尼亚将军是叛徒。因此，假定的解决方案保证了IC1和IC2适用于阿尔巴尼亚将军。在IC1中，所有的阿尔巴尼亚中尉都被模拟成一个忠诚的拜占庭中尉，服从同一条命令，这是他必须服从的命令。很容易检查阿尔巴尼亚将军解的条件IC1和IC2意味着对应的拜占庭将军解的条件，因此我们已经构造了所需的不可能解。
  
One might think that the difficulty in solving the Byzantine Generals Problem stems from the requirement of reaching exact agreement. We now demonstrate that this is not the case by showing that reaching approximate agreement is just as hard as reaching exact agreement. Let us assume that instead of trying to agree on a precise battle plan, the generals must agree only upon an approximate time of attack. More precisely, we assume that the commander orders the time of the attack, and we require the following two conditions to hold:
  
有人可能会认为，解决拜占庭将军问题的困难源于达成确切协议的要求。我们现在通过表明达成近似一致和达成精确一致一样困难来证明，情况并非如此。让我们假设，将领们不必就精确的作战计划达成一致，而只需就大致的进攻时间达成一致。更准确地说，我们假设指挥官下令攻击的时间，我们需要以下两个条件才能维持下去:
  
IC1 '. All loyal lieutenants attack within 10 minutes of one another.
IC2'. If the commanding general is loyal, then every loyal lieutenant attacks within 10 minutes of the time given in the commander's order. 
  
### IC1”。所有忠诚的中尉都在十分钟内互相攻击。
  
### IC2”。如果指挥官是忠诚的，那么每个忠诚的中尉在指挥官命令的10分钟内攻击。
  
(We assume that the orders are given and processed the day before the attack and that the time at which an order is received is irrelevant--only the attack time given in the order matters.} 
  
(我们假设命令是在攻击发生的前一天发出并处理的，而接收到命令的时间是无关紧要的——只有命令中给出的攻击时间是重要的。)  
    
Like the Byzantine Generals Problem, this problem is unsolvable unless more than two-thirds of the generals are loyal. We prove this by first showing that if there were a solution for three generals that coped with one traitor, then we could construct a three-general solution to the Byzantine Generals Problem that also worked in the presence of one traitor. Suppose the commander wishes to send an "attack" or "retreat" order. He orders an attack by sending an attack time of 1:00 and orders a retreat by sending an attack time of 2:00, using the assumed algorithm. Each lieutenant uses the following procedure to obtain his order.
  
就像拜占庭将军问题一样，这个问题是无法解决的，除非超过三分之二的将军是忠诚的。我们首先证明，如果有一个解决方案，可以解决三个将军同时对付一个叛徒，那么我们就可以构建一个解决三将军一叛徒的拜占庭将军问题。假设指挥官想要发出“进攻”或“撤退”的命令。他通过发送1点的攻击时间来命令攻击，通过发送2点的攻击时间来命令撤退，使用假设的算法。每个中尉都使用以下程序来获得命令。
  
#### (1) After receiving the attack time from the commander, a lieutenant does one of the following:  
##### (a) If the time is 1:10 or earlier, then attack.  
##### (b) If the time is 1:50 or later, then retreat.  
##### (c) Otherwise, continue to step (2).   
  
#### (2) Ask the other lieutenant what decision he reached in step (1).  
##### (a) If the other lieutenant reached a decision, then make the same decision he did.  
##### (b) Otherwise, retreat.   
  
It follows from IC2' that if the commander is loyal, then a loyal lieutenant will obtain the correct order in step (1), so IC2 is satisfied. If the commander is loyal, then IC1 follows from IC2, so we need only prove IC1 under the assumption that the commander is a traitor. Since there is at most one traitor, this means that both lieutenants are loyal. It follows from ICI' that if one lieutenant decides to attack in step (1), then the other cannot decide to retreat in step (1). Hence, either they will both come to the same decision in step (1) or at least one of them will defer his decision until step (2). In this case, it is easy to see that they both arrive at the same decision, so IC1 is satisfied. We have therefore constructed a three-general solution to the Byzantine Generals Problem that handles one traitor, which is impossible. Hence, we cannot have a three-general algorithm that maintains ICI' and IC2' in the presence of a traitor. The method of having one general simulate m others can now be used to prove that no solution with fewer than 3rn + 1 generals can cope with m traitors. The proof is similar to the one for the original Byzantine Generals Problem and is left to the reader. 
  
由IC2’可知，如果指挥官是忠诚的，那么忠诚的中尉将在步骤(1)中获得正确的命令，因此IC2是满足的。如果指挥官是忠诚的，那么IC1从IC2继承而来，所以我们只需要在指挥官是叛徒的假设下证明IC1。因为最多有一个叛徒，这意味着两个中尉都是忠诚的。根据ICI'可知，如果一个中尉在步骤(1)中决定进攻，那么另一个中尉在步骤(1)中就不能决定撤退。因此，他们要么在步骤(1)中都做出相同的决定，要么至少有一个会推迟到步骤(2)。在这种情况下，很容易看到他们都做出了相同的决定，所以IC1是满意的。因此，我们建立了一个解决三将军，一叛徒的办法，但这是不可能的。因此，我们不能有一个三将军算法，在叛徒存在的情况下保持ICI'和IC2'。用一个将军模拟m个其他将军模拟的方法现在可以用来证明，没有一个小于3rn + 1个将军的解可以对付m个叛徒。这个证明类似于原来的拜占庭将军问题，留给读者。
  
## 3. A SOLUTION WITH ORAL MESSAGES
  
3.一个口头信息的解决方案
  
We showed above that for a solution to the Byzantine Generals Problem using oral messages to cope with rn traitors, there must be at least 3m + 1 generals. We now give a solution that works for 3m + 1 or more generals. However, we first specify exactly what we mean by "oral messages". Each general is supposed to execute some algorithm that involves sending messages to the other generals, and we assume that a loyal general correctly executes his algorithm. The definition of an oral message is embodied in the following assumptions which we make for the generals' message system:
  
我们在上面展示过，要想解决拜占庭将军问题，用口头信息来对付rn叛徒，至少需要300m + 1名将军。我们现在给出的解决方案适用于3m + 1或更多的将军。然而，我们首先具体说明我们所说的“口头信息”是什么意思。每个将军都应该执行一些算法包括向其他将军发送消息，我们假设一个忠诚的将军正确地执行他的算法。口头信息的定义体现在我们对将军信息系统做出的以下假设:
  
A1. Every message that is sent is delivered correctly.   
A2. The receiver of a message knows who sent it.  
A3. The absence of a message can be detected.  
  
A1. 发送的每个消息都被正确地传递。    
A2. 消息的接收者知道是谁发送的。  
A3. 可以检测到消息的缺失。   
Assumptions A1 and A2 prevent a traitor from interfering with the communication between two other generals, since by A1 he cannot interfere with the messages they do send, and by A2 he cannot confuse their intercourse by introducing spurious messages. Assumption A3 will foil a traitor who tries to prevent a decision by simply not sending messages. The practical implementation of these assumptions is discussed in Section 6.
  
假设A1和A2可以防止叛徒干扰另外两位将军之间的通信，因为A1不能干扰他们实际发送的信息，而A2不能通过引入虚假信息来混淆他们的通信。假设A3将挫败试图通过不发送消息来阻止决策的叛徒。第6节将讨论这些假设的实际实现。
  

The algorithms in this section and in the following one require that each general be able to send messages directly to every other general. In Section 5, we describe algorithms which do not have this requirement.  
A traitorous commander may decide not to send any order. Since the lieuten- ants must obey some order, they need some default order to obey in this case. We let RETREAT be this default order.  
  
本节和下一节中的算法要求每个将军能够直接向其他将军发送消息。在第5节中，我们描述的算法没有这个要求。  
叛国的指挥官可以决定不发出任何命令。由于中尉必须服从某些命令，在这种情况下，他们需要一些默认的命令来服从。我们让撤退成为这个默认的命令。  
  
We inductively define the Oral Message algorithms OM(m), for all nonnegative integers m, by which a commander sends an order to n - 1 lieutenants. We show that OM(m) solves the Byzantine Generals Problem for 3m + 1 or more generals in the presence of at most m traitors. We find it more convenient to describe this algorithm in terms of the lieutenants "obtaining a value" rather than "obeying an order".
  
我们归纳地定义了口头消息算法OM(m)，对于所有非负整数m，指挥官通过它向n - 1个中尉发送命令。我们证明OM(m)在最多m个叛徒存在的情况下，解决了3m + 1或更多将军的拜占庭将军问题。我们发现用中尉“获取一个值”来描述这个算法比用“服从一个命令”来描述更方便。
  
The algorithm assumes a function majority with the property that if a majority of the values vi equal v, then majority (V1,···, vn-1 equals v. (Actually, it assumes a sequence of such functions--one for each n.) There are two natural choices for the value of majority(v1, ..., vn-1):
  
该算法假设函数具有如下属性:如果大多数值vi等于v，那么大多数(V1,···，vn-1)等于v(实际上，它假设有一个这样的函数序列——每个n对应一个函数)。多数的值有两个自然的选择(v1，…, vn-1):
  
1. The majority value among the vi if it exists, otherwise the value RETREAT;  
2. The median of the vi, assuming that they come from an ordered set.     
  
1. 如果存在，则为vi中的多数值，否则为RETREAT值；  
2. vi的中位数，假设它们来自一个有序集合。  
  
The following algorithm requires only the aforementioned property of majority.  
  
下面的算法只需要上述的多数属性。  
  
Algorithm OM(0).  
  
(1) The commander sends his value to every lieutenant.  
(2) Each lieutenant uses the value he receives from the commander, or uses the value RETREAT if he receives no value.  
  
(1) 指挥官将他的值发送给每个中尉。  
(2) 每个中尉使用他从指挥官那里收到的值，如果他没有收到值，则使用RETREAT。  
  
Algorithm OM(m), m > O.  
  
(1) The commander sends his value to every lieutenant.   
(2) For each i, let vi be the value Lieutenant i receives from the commander, or else be RETREAT if he receives no value. Lieutenant i acts as the commander in Algorithm OM(m - 1) to send the value vi to each of the n - 2 other lieutenants.   
(3) For each i, and each j ~ i, let vj be the value Lieutenant i received from Lieutenant j in step (2) (using Algorithm OM(m - 1)), or else RETREAT if he received no such value. Lieutenant i uses the value majority (vl ..... vn-1).   
  
(1) 司令员向每一个中尉报信。  
(2) 对于每一个i, vi为中尉i从指挥官那里得到的值，否则为撤退，如果他没有得到值。中尉i作为算法OM(m - 1)中的指挥官，将值vi发送给n - 2个其他中尉。  
(3) 对于每个i和每个j ~ i，让vj为步骤(2)中中尉i从中尉j处得到的值(使用算法OM(m - 1))，如果没有得到该值则撤退。中尉i使用的值多数(vl .....vn-1)。  
  
To understand how this algorithm works, we consider the case m = 1, n = 4. Figure 3 illustrates the messages received by Lieutenant 2 when the commander sends the value v and Lieutenant 3 is a traitor. In the first step of OM(1), the commander sends v to all three lieutenants. In the second step, Lieutenant 1 sends the value v to Lieutenant 2, using the trivial algorithm OM(0). Also in the second step, the traitorous Lieutenant 3 sends Lieutenant 2 some other value x. In step 3, Lieutenant 2 then has v1 = v2 = v and v3 = x, so he obtains the correct value v = majority(v, v, x).

为了理解这个算法是如何工作的，我们假定 m=1, n=4。图三阐释了，当指挥官发送值v并且当副官3是一名叛徒的时候，副官2接收到的值。第一步OM(1)中，指挥官发送v给所有的副官。第二步，副官1发送v给副官2，使用OM(0)。在第二步，叛徒副官3发送给副官2一些其他值，比如x。第三步，副官2有了v1=v2=v and v3=x，所以它维持了正确的v=majority(v,v,x)。  
  
Next, we see what happens if the commander is a traitor. Figure 4 shows the values received by the lieutenants if a traitorous commander sends three arbitrary values x, y, and z to the three lieutenants. Each lieutenant obtains v1 = x, v2 = y, and v3 = z, so they all obtain the same value majority(x, y, z) in step (3), regardless of whether or not any of the three values x, y, and z are equal.
  
然后，我们再来看如果指挥官是一名叛徒的话，会发生什么。图4展示了副官们接收到的值，当指挥官是叛徒时，他分别发送三个值给三个副官：x,y,z。每个副官保持着v1 = x, v2 = y, and v3 = z，所以他们都保持着相同的majority(x,y,z).
  
The recursive algorithm OM(m) invokes n - 1 separate executions of the algorithm OM(m - 1), each of which invokes n - 2 executions of OM(m - 2), etc. This means that, for m > 1, a lieutenant sends many separate messages to each other lieutenant. There must be some way to distinguish among these different messages. The reader can verify that all ambiguity is removed if each lieutenant i prefixes the number i to the value vi that he sends in step (2). As the recursion "unfolds," the algorithm OM(m - k) will be called (n - 1) ... (n - k) times to send a value prefixed by a sequence of k lieutenants' numbers.
  
递归算法OM(m)调用算法OM(m - 1)的n - 1次单独执行，其每次调用OM(m - 2)的n - 2次执行，以此类推。这意味着，对于m>1，一个中尉向其他每个中尉发送了许多单独的信息。必须有某种方法来区分这些不同的信息。读者可以验证，如果每个中尉i在他在步骤(2)中发送的值vi前加上数字i，那么所有的模糊性都会被消除。随着递归“展开”，算法OM(m-k)将被调用 (n - 1) ... (n - k) 次去发送一个前缀是k个副官序号的序列值的value。
  
To prove the correctness of the algorithm OM{m) for arbitrary m, we first prove the following lemma.
  
为了证明任意m的算法OM(m)的正确性，我们首先要证明以下定理。  
  
LEMMA 1. For any m and k, Algorithm OM (m ) satisfies IC2 if there are more than 2k + m generals and at most k traitors.
  
LEMMA 1. 对于任何m和k，如果有超过2k+m的将军和最多k的叛徒，算法OM（m）满足IC2。
  
PROOF. The proof is by induction on m. IC2 only specifies what must happen if the commander is loyal. Using A1, it is easy to see that the trivial algorithm OM(0) works if the commander is loyal, so the lemma is true for m = 0. We now assume it is true for m-1(m>0), and prove it for m.
  
In step (1), the loyal commander sends a value v to all n - 1 lieutenants. In step (2), each loyal lieutenant applies OM(m - 1) with n - 1 generals. Since by hypothesis n>2k+m, we have n-1>2k+(m- 1),so we can apply the induction hypothesis to conclude that every loyal lieutenant gets vj = v for each loyal Lieutenant j. Since there are at most k traitors, and n - 1 > 2k + (m - 1) > 2k, a majority of the n - 1 lieutenants are loyal. Hence, each loyal lieutenant has vi = v for a majority of the n - 1 values i, so he obtains majority(v1 .... , vn-1) = v in step (3), proving IC2.
  
证明。证明是通过对m的归纳。IC2只规定了如果指挥官是忠诚的，必须发生什么。利用A1，我们很容易看到，如果指挥官是忠诚的，算法OM(0)是有效的，所以该定理对于m=0来说是真的。  
  
在步骤（1）中，忠诚的指挥官向所有n-1名中尉发送一个值v。在步骤（2）中，每个忠诚的中尉向n-1个将军应用OM（m - 1）。由于假设n>2k+m，我们有n-1>2k+(m-1),所以我们可以应用归纳假设得出结论：每个忠诚的中尉j得到vj=v。由于最多只有k个叛徒，而n-1>2k+(m-1)>2k，n-1个中尉的大多数是忠诚的。因此，每个忠诚的中尉在n - 1的大多数值i中都有vi = v，所以他在步骤(3)中得到major(v1 .... , vn-1) = v，证明了IC2。
  
The following theorem asserts that Algorithm OM(m) solves the Byzantine Generals Problem.
    
以下定理断言，算法OM(m)解决了拜占庭将军问题。
  
THEOREM 1. For any m, Algorithm OM (m ) satisfies conditions IC1 and IC2 if there are more than 3m generals and at most m traitors.
  
定理1. 对于任何m，如果有超过3m个将军和最多m个叛徒，则算法OM（m ）满足条件IC1和IC2。  
  
PROOF. The proof is by induction on m. If there are no traitors, then it is easy to see that OM(0) satisfies IC1 and IC2. We therefore assume that the theorem is true for OM(m - 1) and prove it for OM(m), m > 0.   
We first consider the case in which the commander is loyal. By taking k equal to m in Lemma 1, we see that OM(m) satisfies IC2. IC1 follows from IC2 if the commander is loyal, so we need only verify IC1 in the case that the commander is a traitor.  
There are at most m traitors, and the commander is one of them, so at most m - 1 of the lieutenants are traitors. Since there are more than 3m generals, there are more than 3m - 1 lieutenants, and 3m - 1 > 3(m - 1). We may therefore apply the induction hypothesis to conclude that OM(m - 1) satisfies conditions IC1 and IC2. Hence, for each j, any two loyal lieutenants get the same value for vj in step (3). (This follows from IC2 if one of the two lieutenants is Lieutenant j, and from IC1 Otherwise.) Hence, any two loyal lieutenants get the same vector of values vl ..... Vn-1, and therefore obtain the same value majority(vl ..... Vn-1) in step (3), proving IC1.  
  
证明。如果没有叛徒，那么很容易看出OM(0)满足IC1和IC2。因此，我们假设该定理对OM(m - 1)是真的，并对OM(m)，m>0进行证明。  
我们首先考虑司令员是忠诚的情况。通过将k等同于结论1中的m，我们看到OM(m)满足IC2。如果指挥官是忠诚的，IC1由IC2得出，所以我们只需要在指挥官是叛徒的情况下验证IC1。  
最多有m个叛徒，而指挥官是其中之一，所以最多有m-1个中尉是叛徒。由于有超过3米的将军，所以有超过3米-1的中尉，而且3米-1>3（米-1）。因此，我们可以运用归纳假设得出结论：OM(m - 1)满足条件IC1和IC2。因此，对于每个j，任何两个忠诚的副手在步骤（3）中得到的vj值都是一样的。(如果两个中尉中的一个是中尉j，这由IC2得出，否则由IC1得出）。因此，任何两个忠诚的中尉都会得到相同的价值向量vl ..... Vn-1，因此在步骤(3)中获得相同的值 majority(vl ..... Vn-1)，证明了IC1。  
  
## 4. A SOLUTION WITH SIGNED MESSAGES
  
签名消息方案  
  
As we saw from the scenario of Figures 1 and 2, it is the traitors' ability to lie that makes the Byzantine Generals Problem so difficult. The problem becomes easier to solve if we can restrict that ability. One way to do this is to allow the generals to send unforgeable signed messages. More precisely, we add to A1-A3 the A4   
(a) A loyal general's signature cannot be forged, and any alteration of the contents of his signed messages can be detected.   
(b) Anyone can verify the authenticity of a general's signature.  
  
正如我们从图1和图2的情景中看到的那样，正是叛徒的撒谎能力使拜占庭将军问题变得如此困难。如果我们能限制这种能力，问题就会变得更容易解决。做到这一点的一个方法是允许将军们发送不可伪造的签名信息。更确切地说，我们在A1-A3中加入A4  
(a) 忠诚的将军的签名不能被伪造，任何对其签名信息内容的篡改都能被发现。  
(b) 任何人都可以验证一个将军的签名的真实性。  
   
Note that we make no assumptions about a traitorous general's signature. In particular, we allow his signature to be forged by another traitor, thereby permitting collusion among the traitors.  
Now that we have introduced signed messages, our previous argument that four generals are required to cope with one traitor no longer holds. In fact, a three-general solution does exist. We now give an algorithm that copes with m traitors for any number of generals. (The problem is vacuous if there are fewer than m + 2 generals.)
    
请注意，我们对叛国将军的签名不做任何假设。特别是，我们允许他的签名被另一个叛徒伪造，从而允许叛徒之间的勾结。  
既然我们已经引入了签名信息，那么我们之前的论点，即需要四名将军来应对一个叛徒就不再成立了。事实上，一个三将军的解决方案确实存在。我们现在给出一个算法，可以应对任何数量的将军的m个叛徒。(如果少于m+2个将军，这个问题就是没有意义的）。   
  
In our algorithm, the commander sends a signed order to each of his lieutenants. Each lieutenant then adds his signature to that order and sends it to the other lieutenants, who add their signatures and send it to others, and so on. This means that a lieutenant must effectivelyreceive one signed message, make several copies of it, and sign and send those copies. It does not matter how these copies are obtained; a single message might be photocopied, or else each message might consist of a stack of identical messages which are signed and distributed as required.  
  
在我们的算法中，指挥官向他的每个中尉发送一个签名的命令。然后每个中尉在该命令上加上自己的签名，并将其发送给其他中尉，其他中尉再加上自己的签名，并将其发送给其他人，如此反复。这意味着，一个中尉必须有效地接收一份已签署的信息，将其复制几份，并签署和发送这些副本。如何获得这些副本并不重要；一份电文可能是复印的，否则每份电文可能由一叠相同的电文组成，这些电文按要求进行签署和分发。  
  
Our algorithm assumes a function choice which is applied to a set of orders to /obtain a single one. The only requirements we make for this function are  
1. If the set V consists of the single element v, then choice(V) = v.  
2. choice(Q) = RETREAT, where ø is the empty set.    

我们的算法假定有一个函数选择，它被应用于一组命令，以获得一个单一的命令。我们对这个函数的唯一要求是  
1. 如果集合V由单一元素v组成，那么选择(V)=v。  
2. choice(Q) = RETREAT，其中是ø空集。  
  
Note that one possible definition is to let choice(V) be the median element of V -- assuming that there is an ordering of the elements.  
In the following algorithm, we let x:i denote the value x signed by General i. Thus, v:j:i denotes the value v signed by j, and then that value v:j signed by i. We let General 0 be the commander. In this algorithm, each lieutenant i maintains a set Vi, containng the set of properly signed orders he has received so far. (If the commander is loyal, then this set should never contain more than a single element.) Do not confuse Vi, the set of orders he has received, with the set of messages that he has received. There may be many different messages with the same order.
    
请注意，一个可能的定义是让choice(V)是V的中位数元素--假设元素是有序的。  
在下面的算法中，我们让x:i表示由i将军签署的值x。因此，v:j:i表示由j签署的值v，然后是由i签署的那个值v:j。我们让0将军做指挥官。在这个算法中，每个中尉i维护一个集合Vi，包含他迄今为止收到的正确签署的命令集合。(如果指挥官是忠诚的，那么这个集合就不应该包含超过一个元素）。不要把Vi，即他所收到的命令集，与他所收到的信息集混淆起来。同一个命令可能有许多不同的信息。  
  
Algorithm SM (m).

Initially Vi = 0.    
(1) The commander signs and sends his value to every lieutenant.   
(2) For each i:   
&emsp;(A) If Lieutenant i receives a message of the form v:0 from the commander and he has not yet received any order, then   
&emsp;&emsp;(i) he lets V equal (v);    
&emsp;&emsp;(ii) he sends the message v:0:i to everyother lieutenant.     
&emsp;(B) If Lieutenant i receives a message of the form v:0:j1:···:jk and v is not in the set Vi, then  
&emsp;&emsp;(i) he adds v to Vi;  
&emsp;&emsp;(ii) if k < m, then he sends the message v:0:j1:···:jk:i to every lieutenant other than j1.....,jk.  
(3) For each i: When Lieutenant i will receive no more messages, he obeys the order choice(Vi).  
  
最初，Vi = 0。  
(1) 指挥官签署并将他的命令发送给每个中尉。  
(2) 对于每个i：  
&emsp;(A) 如果i中尉从指挥官那里收到形式为v:0的信息，并且他还没有收到任何命令，那么   
&emsp;&emsp;(i) 他让V等于（v）。  
&emsp;&emsp;(ii)他将信息v:0:i发送给其他所有的中尉。  
&emsp;(B) 如果i中尉收到一个形式为v:0:j1:--:jk的信息，并且v不在集合V中，那么  
&emsp;&emsp;(i) 他将v加入Vi。  
&emsp;&emsp;(ii) 如果k < m，那么他将信息v:0:j1:---:jk:i发送给除j1.....,jk之外的每个中尉。  
(3) 对于每个i。当中尉i不会再收到信息时，他就会服从choice(Vi)的命令。  
  
Note that in step (2), Lieutenant i ignores any message containing an order v that is already in the set Vi.  
  
请注意，在步骤（2）中，中尉i会忽略任何包含已经在集合Vi中的命令v的消息。

We have not specified how a lieutenant determines in step (3) that he will receive no more messages. By induction on k, one easily shows that for each sequence of lieutenants j1, ···, jk with k<=m, a lieutenant can receive at most one message of the form v:0:j1:···:jk in step (2). If we require that Lieutenant jk either send such a message or else send a message reporting that he will not send such a message, then it is easy to decide when all messages have been received. (By assumption A3, a lieutenant can determine if a traitorous lieutenant jk sends neither of those two messages.) Alternatively, time-out can be used to determine when no more messages will arrive. The use of time-out is discussed in Section 6.  
  
我们没有说明中尉如何在步骤(3)中确定他不会再收到信息。通过对k的归纳，我们很容易发现，对于每一个k<=m的中尉序列j1, ---, jk，一个中尉在步骤(2)中最多可以收到一条形式为v:0:j1:---:jk的信息。如果我们要求中尉jk要么发送这样的信息，要么发送一个报告他不会发送这样的信息的信息，那么很容易决定何时所有信息都被收到了。(根据假设A3，中尉可以判断出叛徒中尉jk是否不发送这两条信息)。另外，也可以用超时来决定何时不再有信息到达。第6节将讨论超时的使用。  
  
Note that in step (2), Lieutenant i ignores any messages that do not have the proper form of a value followed by a string of signatures. If packets of identical messages are used to avoid having to copy messages, this means that he throws away any packet that does not consist of a sufficient number of identical, properly signed messages.(There should be(n-k-2)(n-k-3)···(n-m-2)copies of the message if it has been signed by k lieutenants.)
  
请注意，在步骤(2)中，中尉i忽略了任何没有正确形式的信息，即一个值后面有一串签名的信息。如果使用相同的信息包来避免复制信息，这意味着他扔掉任何不包含足够数量的相同的、正确签名的信息包。（如果信息已经被k个中尉签名，应该有(n-k-2)(n-k-3)---(n-m-2)份。）  
  
Figure 5 illustrates Algorithm SM(1) for the case of three generals when the commander is a traitor. The commander sends an "attack" order to one lieutenant and a "retreat" order to the other. Both lieutenants receive the two orders in step (2), so after step (2) V1 = V2 = {"attack", "retreat"}, and they both obey the order choice( {"attack", "retreat"} ). Observe that here, unlike the situation in Figure 2, the lieutenants know the commander is a traitor because his signature appears on two different orders, and A4 states that only he could have generated those signatures.   
In Algorithm SM(m), a lieutenant signs his name to acknowledge his receipt of an order. If he is the mth lieutenant to add his signature to the order, then that signature is not relayed to anyone else by its recipient, so it is superfluous. (More precisely, assumption A2 makes it unnecessary.) In particular, the lieutenants need not sign their messages in SM(1).  
  
图5说明了当指挥官是叛徒时三个将军的情况下的算法SM(1)。指挥官向一名中尉发出了 "攻击 "命令，向另一名中尉发出了 "撤退 "命令。两个中尉在步骤（2）中都收到了这两个命令，所以在步骤（2）之后，V1=V2={"进攻"，"撤退"}，他们都服从命令选择（{"进攻"，"撤退"}）。请注意，这里与图2的情况不同，中尉们知道指挥官是个叛徒，因为他的签名出现在两个不同的命令上，而且A4说只有他才能产生这些签名。   
在算法SM(m)中，一名中尉签署了他的名字，以确认他收到了一份命令。如果他是第m个在命令上签名的中尉，那么这个签名就不会被其接收者转达给其他人，所以它是多余的。(更确切地说，假设A2使其成为不必要的。)特别是，中尉们不需要在SM(1)中签署他们的信息。  
  
We now prove the correctness of our algorithm.
  
证明算法
  
THEOREM 2. For any m, Algorithm SM(m) solves the Byzantine Generals Problem if there are at most m traitors.
  
定理2. 对于任何m，如果有最多m个叛徒，算法SM(m)可以解决拜占庭将军问题。
  
PROOF. We first prove IC2. If the commander is loyal, then he sends his signed order v:0 to every lieutenant in step (1). Every loyal lieutenant will therefore receive the order v in step (2)(A). Moreover, since no traitorous lieutenant can forge any other message of the form v':0, a loyal lieutenant can receive no additional order in step (2)(B). Hence, for each loyal Lieutenant i, the set Vi obtained in step (2) consists of the single order v, which he will obey in step (3) by property 1 of the choice function. This proves IC2.   
Since IC1 follows from IC2 if the commander is loyal, to prove IC1 we need only consider the case in which the commander is a traitor. Two loyal lieutenants i and j obey the same order in step (3) if the sets of orders Vi and Vj that they receive in step (2) are the same. Therefore, to prove IC1 it suffices to prove that, if i puts an order v into Vi in step (2), thenj must put the same order v into V1in step (2). To do this, we must show that j receives a properly signed message containing that order. If i receives the order v in step (2)(A), then he sends it to
j in step (2)(A)(ii); so j receives it (by A1). If i adds the order to Vi in step (2)(B), then he must receive a first message of the form v:0 :j1:···:jk. If j is one of the jr, then by A4 he must already have received the order v. If not, we consider two cases:  
  
1. k < m. In this case, i sends the message v:0:j1: ... :jk:i to j; soj must receive the order v.  
2. k = m. Since the commander is a traitor, at most m - 1 of the lieutenants are traitors. Hence, at least one of the lieutenants j1, .... , jm is loyal. This loyal lieutenant must have sent j the value v when he first received it, so j must therefore receive that value.  

证明。我们首先证明IC2。如果指挥官是忠诚的，那么他在步骤(1)中向每个中尉发送了他签署的命令v:0。因此，每个忠诚的中尉都会在步骤（2）（A）中收到命令v。此外，由于没有一个叛徒中尉可以伪造任何其他形式的v':0的信息，忠诚的中尉在步骤(2)(B)中无法收到任何额外的命令。因此，对于每个忠诚的中尉i来说，在步骤(2)中得到的集合Vi包括单一的命令v，根据选择函数的属性1，他将在步骤(3)中服从这个命令。这就证明了IC2。  
由于如果指挥官是忠诚的，则IC1由IC2得出，为了证明IC1，我们只需要考虑指挥官是叛徒的情况。如果两个忠诚的中尉i和j在步骤(3)中接受的命令集Vi和Vj是相同的，那么他们在步骤(2)中就会服从同一个命令。因此，要证明IC1，只需证明，如果i在步骤(2)中将一个命令v放入Vi中，那么j在步骤(2)中必须将同样的命令v放入V1中。要做到这一点，我们必须证明j收到一个包含该命令的正确签名信息。如果i在步骤(2)(A)中收到了命令v，那么他就把它发送给了j, 在步骤(2)(A)(ii)中；所以j收到了它（通过A1）。如果i在步骤(2)(B)中将订单添加到Vi中，那么他必须收到形式为v:0 :j1:---:jk的第一个信息。如果j是jr之一，那么根据A4，他一定已经收到了订单v。 如果不是，我们考虑两种情况:  
  
1.在这种情况下，i向j发送了v:0:j1:...:jk:i的信息；所以j必须接受命令v。  
  
2.k=m。由于指挥官是叛徒，所以最多只有m-1名中尉是叛徒。因此，至少有一个中尉j1, .... , jm是忠诚的。这个忠诚的中尉在第一次收到价值v的时候，一定给j发送了这个命令，因此j一定会收到这个命令。   
  
## 5. MISSING COMMUNICATION PATHS  
  
Thus far, we have assumed that a general can send messages directly to every other general. We now remove this assumption. Instead, we suppose that physical barriers place some restrictions on who can send messages to whom. We consider the generals to form the nodes of a simple, finite undirected graph G, where an arc between two nodes indicates that those two generals can send messages directly to one another. We now extend Algorithms OM(m) and SM(m), which assumed G to be completely connected, to more general graphs.  
To extend our oral message algorithm OM(m), we need the following definition, where two generals are said to be neighbors if they are joined by an arc.  
  
到目前为止，我们假设一个将军可以直接向其他每个将军发送信息。现在我们取消这一假设。相反，我们假设物理屏障对谁能向谁发送信息有一些限制。我们认为将军们构成了一个简单的、有限的无向图G的节点，其中两个节点之间的弧表示这两个将军可以直接向对方发送消息。现在我们将假设G是完全连接的算法OM(m)和SM(m)扩展到更一般的图。  
为了扩展我们的口头信息算法OM(m)，我们需要以下定义，如果两个将军被一条弧连接，就说它们是邻居。   
  
Definition 1.  
  
&emsp;(a) A set of nodes (il, ..., ip} is said to be a regular set of neighbors of a node if  
&emsp;&emsp;(i) each ij is a neighbor of i, and
&emsp;&emsp;(ii) for any general k different from i, there exist paths yj,kfrom ijto k not passing through i such that any two different paths Yi,khave no node in common other than k.
  
定义1.  
&emsp;(a) 一组节点（il，...，ip}被称为是一个节点的常规邻居集，如果  
&emsp;&emsp;(i) 每个ij都是i的邻居，并且  
&emsp;&emsp;(ii) 对于任何不同于i的k，存在从ij到k的不经过i的路径yj,k，使得任何两个不同的路径Yi,k除了k之外没有共同的节点。  

&emsp;(b) The graph G is said to be p-regular if every node has a regular set of neighbors consisting of p distinct nodes.  
  
&emsp;(b) 如果每个节点都有一个由p个不同节点组成的规则的邻居集，则称图G为p-规则。  
  
Figure 6 shows an example of a simple 3-regular graph. Figure 7 shows an example of a graph that is not 3-regular because the central node has no regular set of neighbors containing three nodes.  
  
图6是一个简单的3-规则图的例子。图7显示了一个非3规则图的例子，因为中心节点没有包含三个节点的规则邻居集。  
  
We extend OM(m) to an algorithm that solves the Byzantine Generals Problem in the presence of m traitors if the graph G of generals is 3m-regular. (Note that a 3m-regular graph must contain at least 3m + 1 nodes.} For all positive integers m and p, we define the algorithm OM(m, p) as follows when the graph G of generals is p-regular. (OM(m,p) is not defined if G is not p-regular.) The definition uses induction on m.  
  
我们将OM(m)扩展为一种算法，如果图G是3m规则的，那么在有m个叛徒的情况下，可以解决拜占庭将军问题。(请注意，一个3m规则的图必须至少包含3m+1个节点)。对于所有正整数m和p，当将军图G是p-regular时，我们定义算法OM(m, p)如下。(如果G不是p-regular，OM(m,p)就没有定义) 。该定义使用了对m的归纳法。
  
Algorithm OM(m,p).
  
&emsp;(0) Choose a regular set N of neighbors of the commander consisting ofp lieutenants.  
&emsp;(1) The commander sends his value to every lieutenant in N.  
&emsp;(2) For each i in N, let vi be the value Lieutenant i receives from the commander, or else RETREAT if he receives no value. Lieutenant i sends vi to every other lieutenant k as follows:  
&emsp;&emsp;(A) If m = 1, then by sending the value along the path yi,k whose existence is guaranteed by part (a)(ii) of Definition 1.  
&emsp;&emsp;(B) If rn > 1, then by acting as the commander in the algorithm OM(m - 1, p - 1), with the graph of generals obtained by removing the original commander from G.  
&emsp;(3) For each k, and each i in N with i ~ k, let vi be the value Lieutenant k received from Lieutenant i in step (2), or RETREAT if he received no value. Lieutenant k uses the value majority(vi...... vi,), where N = {il..... ip}.
  
&emsp;(0) 选择一个由p个中尉组成的指挥官的常规邻居集N。  
&emsp;(1) 指挥官向N中的每个中尉发送他的命令。  
&emsp;(2) 对于N中的每一个i，让vi成为i中尉从指挥官那里收到的命令，如果他没有收到任何价值，则RETREAT。中尉i将vi发送给其他每个中尉k，如下所示。  
&emsp;&emsp;(A) 如果m=1，那么通过沿路径yi,k发送命令，其存在由定义1的(a)(ii)部分保证。  
&emsp;&emsp;(B) 如果m>1，那么通过在算法OM(m - 1, p - 1)中充当指挥官，通过从G中删除原指挥官得到将军图。  
&emsp;(3) 对于每个k，以及N中的每个i，i ~ k，让vi为k中尉在步骤(2)中从i中尉那里收到的命令，如果他没有收到命令，则RETREAT。中尉k使用价值 majority(vi......vi)其中N = {i1..... ip}。  
  
Note that removing a single node from a p-regular graph leaves a (p - 1) regular graph. Hence, one can apply the algorithm OM(m - 1, p - 1) in step (2)(B).
  
请注意，从一个p-regular图中移除一个节点，会留下一个（p - 1）regular图。因此，我们可以在步骤(2)(B)中应用算法OM(m - 1, p - 1)。
  
We now prove that OM(m, 3m) solves the Byzantine Generals Problem if there are at most m traitors. The proof is similar to the proof for the algorithm OM(m) and will just be sketched. It begins with the following extension of Lemma 1.
  
我们现在证明OM(m, 3m)解决了拜占庭将军问题，如果有最多m个叛徒的话。该证明与OM(m)算法的证明类似，将只是略加说明。它从以下对结论1的扩展开始。  
  
LEMMA 2. For any m > 0 and any p > 2k + m, Algorithm OM (m, p) satisfies IC2 if there are at most k traitors.  
  
LEMMA 2. 对于任何m>0和任何p>2k+m，如果最多有k个叛徒，那么算法OM（m，p）满足IC2。
  
PROOF. For m=1, observe that a lieutenant obtains the value majority(v1, ..., vp), where each vi is a value sent to him by the commander along a path disjoint from the path used to send the other values to him. Since there are at most k traitors and p = 2k + 1, more than half of those paths are composed entirely of loyal lieutenants. Hence, if the commander is loyal, then a majority of the values vi will equal the value he sent, which implies that IC2 is satisfied.   
Now assume the lemma for m - 1, m > 1. If the commander is loyal, then each of the p lieutenants in N gets the correct value. Since p > 2k, a majority of them are loyal, and by the induction hypothesis each of them sends the correct value to every loyal lieutenant. Hence, each loyal lieutenant gets a majority of correct values, thereby obtaining the correct value in step (3).  
  
证明。对于m=1，观察一下，一个中尉获得的值是 majority(v1, ..., vp)，其中每个vi是由指挥官沿着与用来发送其他值的路径不相交的路径发送给他的一个值。由于最多只有k个叛徒，p=2k+1，这些路径中有一半以上完全由忠诚的中尉组成。因此，如果指挥官是忠诚的，那么大多数的值将等于他发送的值，这意味着IC2被满足。  
现在假设m-1，m>1的定理。如果指挥官是忠诚的，那么N中的p个中尉都会得到正确的价值。由于p>2k，他们中的大多数人都是忠诚的，根据归纳假设，他们中的每一个人都向每个忠诚的中尉发送了正确的价值。因此，每个忠诚的中尉都得到了大多数的正确值，从而得到了步骤（3）中的正确值。  
  
The correctness of Algorithm OM(m, 3m) is an immediate consequence of the following result.  
  
算法OM(m, 3m)的正确性是以下结果的直接结果。
  
THEOREM 3. For any m > 0 and any p > 3m, Algorithm OM(m, p) solves the Byzantine Generals Problem if there are at most m traitors.  
  
PROOF. By Lemma 2, letting k = m, we see that OM(m, p) satisfies IC2. If the commander is loyal, then IC1 follows from IC2, so we need only prove IC1 under the assumption that the commander is a traitor. To do this, we prove that every loyal lieutenant gets the same set of values vi in step (3). If m = 1, then this follows because all the lieutenants, including those in N, are loyal and the paths yi,k do not pass through the commander. For m > 1, a simple induction argument can be applied, since p-1>=3m implies that p-1>=3(m - 1).
  
定理3. 对于任何m>0和任何p>3m，如果有最多m个叛徒，算法OM(m, p)就能解决拜占庭将军问题。  
  
证明。根据定理2，让k=m，我们看到OM(m, p)满足IC2。如果指挥官是忠诚的，那么IC1由IC2得出，所以我们只需要在指挥官是叛徒的假设下证明IC1。要做到这一点，我们要证明每个忠诚的中尉在步骤（3）中得到相同的价值集。如果m=1，那么这就意味着，所有的中尉，包括N中的中尉，都是忠诚的，而且路径yi,k不经过司令官。对于m>1，可以应用一个简单的归纳论证，因为p-1>=3m意味着p-1>=3（m - 1）。  
  
Our extension of Algorithm OM(m) requires that the graph G be 3m-regular, which is a rather strong connectivity hypothesis. 3 In fact, if there are only 3m + 1 generals (the minimum number required), then 3m-regularity means complete connectivity, and Algorithm OM(m, 3m) reduces to Algorithm OM(m). In contrast, Algorithm SM(m) is easily extended to allow the weakest possible connectivity hypothesis. Let us first consider how much connectivity is needed for the Byzantine Generals Problem to be solvable. IC2 requires that a loyal lieutenant obey a loyal commander. This is clearly impossible if the commander cannot communicate with the lieutenant. In particular, if every message from the commander to the lieutenant must be relayed by traitors, then there is no way to guarantee that the lieutenant gets the commander's order. Similarly, IC1 cannot be guaranteed if there are two lieutenants who can only communicate with one another via traitorous intermediaries.  
  
The weakest connectivity hypothesis for which the Byzantine Generals Problem is solvable is that the subgraph formed by the loyal generals be connected. We show that under this hypothesis, the algorithm SM(n - 2) is a solution, where n is the number of generals--regardless of the number of traitors. Of course, we must modify the algorithm so that generals only send messages to where they can be sent. More precisely, in step (1), the commander sends his signed order only to his neighboring lieutenants; and in step (2)(B), Lieutenant i only sends the message to every neighboring lieutenant not among the jr.   
  
我们对算法OM(m)的扩展要求图G是3m-规则的，这是一个相当强的连接性假设。3 事实上，如果只有3m+1个将军（所需的最小数量），那么3m-规则性就意味着完全连通性，而算法OM(m, 3m)就简化为算法OM(m)。相比之下，算法SM(m)很容易扩展到允许最弱的连接性假设。让我们首先考虑拜占庭将军问题需要多少连通性才能被解决。IC2要求一个忠诚的中尉服从一个忠诚的指挥官。如果指挥官不能与中尉沟通，这显然是不可能的。特别是，如果从指挥官到中尉的每条信息都必须由叛徒转达，那么就没有办法保证中尉得到指挥官的命令。同样，如果有两个中尉只能通过叛徒的中间人相互沟通，那么IC1也无法保证。  
  
拜占庭将军问题可解的最弱连接性假设是，由忠诚的将军们形成的子图是连接的。我们表明，在这个假设下，算法SM(n - 2)是一个解决方案，其中n是将军的数量--无论叛徒的数量如何。当然，我们必须修改算法，使将军们只把信息发送到可以发送的地方。更确切地说，在步骤(1)中，指挥官只将他签署的命令发送给他邻近的中尉；而在步骤(2)(B)中，中尉i只将信息发送给每一个不在jr的邻近中尉。  
  
We prove the following more general result, where the diameter of a graph is the smallest number d such that any two nodes are connected by a path containing at most d arcs.  
  
我们证明以下更一般的结果，图的直径是最小的数字d，即任何两个节点都由最多包含d个弧的路径连接。
  
THEOREM 4. For any m and d, if there are at most m traitors and the subgraph of loyal generals has diameter d, then Algorithm SM(m + d - 1) (with the above modification) solves the Byzantine Generals Problem.  
  
定理4. 对于任何m和d，如果最多存在m个叛徒，并且忠诚将军的子图的直径为d，那么算法SM(m + d - 1)（经过上述修改）可以解决拜占庭将军问题。  
  
PROOF. The proof is quite similar to that of Theorem 2 and is just sketched here. To prove IC2, observe that by hypothesis there is a path from the loyal commander to a lieutenant i going through d - 1 or fewer loyal lieutenants. Those lieutenants will correctly relay the order until it reaches i. As before, assumption A4 prevents a traitor from forging a different order.  
To prove IC1, we assume the commander is a traitor and must show that any order received by a loyal lieutenant i is also received by a loyal lieutenant j. Suppose i receives an order v:0:j1:···:jk not signed by j. If k < m, then i will send it to every neighbor who has not already received that order, and it will be relayed to j within d - 1 more steps. If k > m, then one of the first m signers must be loyal and must have sent it to all of his neighbors, whereupon it will be relayed by loyal generals and will reach j within d - 1 steps.  
  
证明。该证明与定理2非常相似，在此仅作简要说明。为了证明IC2，请注意，根据假设，有一条从忠诚的指挥官到中尉i的路径要经过d-1或更少的忠诚中尉。这些中尉将正确地转达命令，直到它到达i。如前所述，假设A4防止叛徒伪造不同的命令。  
为了证明IC1，我们假设指挥官是个叛徒，并且必须证明忠心的中尉i收到的任何命令也会被忠心的中尉j收到。假设i收到一个没有j签名的命令v:0:j1:--:jk。如果k>m，那么前m个签名者中的一个一定是忠诚的，而且一定是把它发送给了他的所有邻居，这时它将被忠诚的将军们转发，并在d-1步内到达j。  
  
COROLLARY. If the graph of loyal generals is connected, then SM(n - 2) (as modified above) solves the Byzantine Generals Problem for n generals.  
  
推论。如果忠诚将军的图是连接的，那么SM(n - 2)(如上文所修改)解决了n个将军的拜占庭将军问题。  
  
PROOF. Let d be the diameter of the graph of loyal generals. Since the diameter of a connected graph is less than the number of nodes, there must be more than d loyal generals and fewer than n - d traitors. The result follows from the theorem by letting m=n - d - 1.  
  
证明。设d为忠诚将军图的直径。由于连通图的直径小于节点数，所以忠诚的将军一定多于d，而叛徒一定少于n-d。由定理可知，结果是让m=n - d - 1。
  
Theorem 4 assumes that the subgraph of loyal generals is connected. Its proof is easily extended to show that even if this is not the case, if there are at most m traitors, then the algorithm SM(m + d - 1) has the following two properties:  
  
1. Any two loyal generals connected by a path of length at most d passing through only loyal generals will obey the same order.   
2. If the commander is loyal, then any loyal lieutenant connected to him by a path of length at most m + d passing only through loyal generals will obey his order.  
  
定理4 假设忠诚将军的子图是连接的。它的证明很容易扩展到表明，即使不是这样，如果有最多m个叛徒，那么算法SM(m + d - 1)有以下两个特性。
  
1. 任何两个忠诚的将军被一条最多通过忠诚将军的长度为d的路径所连接，都将服从相同的命令。  
2. 如果指挥官是忠诚的，那么任何与他相连的忠诚的中尉，通过一条长度最多为m+d的路径，只经过忠诚的将军，都会服从他的命令。  
