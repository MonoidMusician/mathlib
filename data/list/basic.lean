/-
Copyright (c) 2014 Parikshit Khanna. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Parikshit Khanna, Jeremy Avigad, Leonardo de Moura, Floris van Doorn, Mario Carneiro

Basic properties of lists.
-/
import tactic.interactive algebra.group logic.basic logic.function
       data.nat.basic data.option data.bool data.prod data.sigma
open function nat

namespace list
universes u v w
variables {α : Type u} {β : Type v} {γ : Type w}

@[simp] theorem cons_ne_nil (a : α) (l : list α) : a::l ≠ [].

theorem head_eq_of_cons_eq {h₁ h₂ : α} {t₁ t₂ : list α} :
      (h₁::t₁) = (h₂::t₂) → h₁ = h₂ :=
assume Peq, list.no_confusion Peq (assume Pheq Pteq, Pheq)

theorem tail_eq_of_cons_eq {h₁ h₂ : α} {t₁ t₂ : list α} :
      (h₁::t₁) = (h₂::t₂) → t₁ = t₂ :=
assume Peq, list.no_confusion Peq (assume Pheq Pteq, Pteq)

theorem cons_inj {a : α} : injective (cons a) :=
assume l₁ l₂, assume Pe, tail_eq_of_cons_eq Pe

@[simp] theorem cons_inj' (a : α) {l l' : list α} : a::l = a::l' ↔ l = l' :=
⟨λ e, cons_inj e, congr_arg _⟩

/- mem -/

theorem eq_nil_of_forall_not_mem : ∀ {l : list α}, (∀ a, a ∉ l) → l = nil
| []        := assume h, rfl
| (b :: l') := assume h, absurd (mem_cons_self b l') (h b)

theorem mem_singleton_self (a : α) : a ∈ [a] := mem_cons_self _ _

theorem eq_of_mem_singleton {a b : α} : a ∈ [b] → a = b :=
assume : a ∈ [b], or.elim (eq_or_mem_of_mem_cons this)
  (assume : a = b, this)
  (assume : a ∈ [], absurd this (not_mem_nil a))

@[simp] theorem mem_singleton {a b : α} : a ∈ [b] ↔ a = b :=
⟨eq_of_mem_singleton, by intro h; simp [h]⟩

theorem mem_of_mem_cons_of_mem {a b : α} {l : list α} : a ∈ b::l → b ∈ l → a ∈ l :=
assume ainbl binl, or.elim (eq_or_mem_of_mem_cons ainbl)
  (assume : a = b, begin subst a, exact binl end)
  (assume : a ∈ l, this)

theorem not_mem_append {a : α} {s t : list α} (h₁ : a ∉ s) (h₂ : a ∉ t) : a ∉ s ++ t :=
mt mem_append.1 $ not_or_distrib.2 ⟨h₁, h₂⟩

theorem length_eq_zero {l : list α} : length l = 0 ↔ l = [] :=
⟨eq_nil_of_length_eq_zero, λ h, h.symm ▸ rfl⟩

theorem length_pos_of_mem {a : α} : ∀ {l : list α}, a ∈ l → 0 < length l
| (b::l) _ := zero_lt_succ _

theorem exists_mem_of_length_pos : ∀ {l : list α}, 0 < length l → ∃ a, a ∈ l
| (b::l) _ := ⟨b, mem_cons_self _ _⟩

theorem length_pos_iff_exists_mem {l : list α} : 0 < length l ↔ ∃ a, a ∈ l :=
⟨exists_mem_of_length_pos, λ ⟨a, h⟩, length_pos_of_mem h⟩

theorem mem_split {a : α} {l : list α} (h : a ∈ l) : ∃ s t : list α, l = s ++ a :: t :=
begin
  induction l with b l ih; simp at h; cases h with h h,
  { subst h, exact ⟨[], l, rfl⟩ },
  { cases ih h with s e, cases e with t e,
    subst l, exact ⟨b::s, t, rfl⟩ }
end

theorem mem_of_ne_of_mem {a y : α} {l : list α} (h₁ : a ≠ y) (h₂ : a ∈ y :: l) : a ∈ l :=
or.elim (eq_or_mem_of_mem_cons h₂) (λe, absurd e h₁) (λr, r)

theorem ne_of_not_mem_cons {a b : α} {l : list α} : a ∉ b::l → a ≠ b :=
assume nin aeqb, absurd (or.inl aeqb) nin

theorem not_mem_of_not_mem_cons {a b : α} {l : list α} : a ∉ b::l → a ∉ l :=
assume nin nainl, absurd (or.inr nainl) nin

theorem not_mem_cons_of_ne_of_not_mem {a y : α} {l : list α} : a ≠ y → a ∉ l → a ∉ y::l :=
assume p1 p2, not.intro (assume Pain, absurd (eq_or_mem_of_mem_cons Pain) (not_or p1 p2))

theorem ne_and_not_mem_of_not_mem_cons {a y : α} {l : list α} : a ∉ y::l → a ≠ y ∧ a ∉ l :=
assume p, and.intro (ne_of_not_mem_cons p) (not_mem_of_not_mem_cons p)

theorem mem_map_of_mem (f : α → β) {a : α} {l : list α} (h : a ∈ l) : f a ∈ map f l :=
begin
  induction l with b l' ih,
  {simp at h, contradiction },
  {simp, simp at h, cases h with h h,
    {simp *},
    {exact or.inr (ih h)}}
end

theorem exists_of_mem_map {f : α → β} {b : β} {l : list α} (h : b ∈ map f l) : ∃ a, a ∈ l ∧ f a = b :=
begin
  induction l with c l' ih,
  {simp at h, contradiction},
  {cases (eq_or_mem_of_mem_cons h) with h h,
    {existsi c, simp [h]},
    {cases ih h with a ha, cases ha with ha₁ ha₂,
      existsi a, simp * }}
end

@[simp] theorem mem_map {f : α → β} {b : β} {l : list α} : b ∈ map f l ↔ ∃ a, a ∈ l ∧ f a = b :=
⟨exists_of_mem_map, λ ⟨a, la, h⟩, by rw [← h]; exact mem_map_of_mem f la⟩

@[simp] theorem mem_map_of_inj {f : α → β} (H : injective f) {a : α} {l : list α} :
  f a ∈ map f l ↔ a ∈ l :=
⟨λ m, let ⟨a', m', e⟩ := exists_of_mem_map m in H e ▸ m', mem_map_of_mem _⟩

@[simp] theorem mem_join {a : α} : ∀ {L : list (list α)}, a ∈ join L ↔ ∃ l, l ∈ L ∧ a ∈ l
| []       := ⟨false.elim, λ⟨_, h, _⟩, false.elim h⟩
| (c :: L) := by simp [join, @mem_join L, or_and_distrib_right, exists_or_distrib]

theorem exists_of_mem_join {a : α} {L : list (list α)} : a ∈ join L → ∃ l, l ∈ L ∧ a ∈ l :=
mem_join.1

theorem mem_join_of_mem {a : α} {L : list (list α)} {l} (lL : l ∈ L) (al : a ∈ l) : a ∈ join L :=
mem_join.2 ⟨l, lL, al⟩

@[simp] theorem mem_bind {b : β} {l : list α} {f : α → list β} : b ∈ list.bind l f ↔ ∃ a ∈ l, b ∈ f a :=
iff.trans mem_join
  ⟨λ ⟨l', h1, h2⟩, let ⟨a, al, fa⟩ := exists_of_mem_map h1 in ⟨a, al, fa.symm ▸ h2⟩,
  λ ⟨a, al, bfa⟩, ⟨f a, mem_map_of_mem _ al, bfa⟩⟩

theorem exists_of_mem_bind {b : β} {l : list α} {f : α → list β} : b ∈ list.bind l f → ∃ a ∈ l, b ∈ f a :=
mem_bind.1

theorem mem_bind_of_mem {b : β} {l : list α} {f : α → list β} {a} (al : a ∈ l) (h : b ∈ f a) : b ∈ list.bind l f :=
mem_bind.2 ⟨a, al, h⟩

/- list subset -/

theorem subset_def {l₁ l₂ : list α} : l₁ ⊆ l₂ ↔ ∀ ⦃a : α⦄, a ∈ l₁ → a ∈ l₂ := iff.rfl

theorem subset_app_of_subset_left (l l₁ l₂ : list α) : l ⊆ l₁ → l ⊆ l₁++l₂ :=
λ s, subset.trans s $ subset_append_left _ _

theorem subset_app_of_subset_right (l l₁ l₂ : list α) : l ⊆ l₂ → l ⊆ l₁++l₂ :=
λ s, subset.trans s $ subset_append_right _ _

@[simp] theorem cons_subset {a : α} {l m : list α} :
  a::l ⊆ m ↔ a ∈ m ∧ l ⊆ m :=
by simp [subset_def, or_imp_distrib, forall_and_distrib]

theorem cons_subset_of_subset_of_mem {a : α} {l m : list α}
  (ainm : a ∈ m) (lsubm : l ⊆ m) : a::l ⊆ m :=
cons_subset.2 ⟨ainm, lsubm⟩ 

theorem app_subset_of_subset_of_subset {l₁ l₂ l : list α} (l₁subl : l₁ ⊆ l) (l₂subl : l₂ ⊆ l) :
  l₁ ++ l₂ ⊆ l :=
λ a h, (mem_append.1 h).elim (@l₁subl _) (@l₂subl _)

theorem eq_nil_of_subset_nil : ∀ {l : list α}, l ⊆ [] → l = []
| []     s := rfl
| (a::l) s := false.elim $ s $ mem_cons_self a l

theorem eq_nil_iff_forall_not_mem {l : list α} : l = [] ↔ ∀ a, a ∉ l :=
show l = [] ↔ l ⊆ [], from ⟨λ e, e ▸ subset.refl _, eq_nil_of_subset_nil⟩

/- append -/

theorem append_ne_nil_of_ne_nil_left (s t : list α) : s ≠ [] → s ++ t ≠ [] :=
by induction s; intros; contradiction

theorem append_ne_nil_of_ne_nil_right (s t : list α) : t ≠ [] → s ++ t ≠ [] :=
by induction s; intros; contradiction

theorem append_foldl (f : α → β → α) (a : α) (s t : list β) : foldl f a (s ++ t) = foldl f (foldl f a s) t :=
by {induction s with b s H generalizing a, refl, simp [foldl], rw H _}

theorem append_foldr (f : α → β → β) (a : β) (s t : list α) : foldr f a (s ++ t) = foldr f (foldr f a t) s :=
by {induction s with b s H generalizing a, refl, simp [foldr], rw H _}

@[simp] lemma append_eq_nil (p q : list α) : (p ++ q) = [] ↔ p = [] ∧ q = [] :=
by cases p; simp

/- join -/

attribute [simp] join

@[simp] theorem join_append (L₁ L₂ : list (list α)) : join (L₁ ++ L₂) = join L₁ ++ join L₂ :=
by induction L₁; simp *

/- repeat take drop -/

/-- Split a list at an index. `split 2 [a, b, c] = ([a, b], [c])` -/
def split_at : ℕ → list α → list α × list α
| 0        a         := ([], a)
| (succ n) []        := ([], [])
| (succ n) (x :: xs) := let (l, r) := split_at n xs in (x :: l, r)

@[simp] theorem split_at_eq_take_drop : ∀ (n : ℕ) (l : list α), split_at n l = (take n l, drop n l)
| 0        a         := rfl
| (succ n) []        := rfl
| (succ n) (x :: xs) := by simp [split_at, split_at_eq_take_drop n xs]

@[simp] theorem take_append_drop : ∀ (n : ℕ) (l : list α), take n l ++ drop n l = l
| 0        a         := rfl
| (succ n) []        := rfl
| (succ n) (x :: xs) := by simp [take_append_drop n xs]

-- TODO(Leo): cleanup proof after arith dec proc
theorem append_inj : ∀ {s₁ s₂ t₁ t₂ : list α}, s₁ ++ t₁ = s₂ ++ t₂ → length s₁ = length s₂ → s₁ = s₂ ∧ t₁ = t₂
| []      []      t₁ t₂ h hl := ⟨rfl, h⟩
| (a::s₁) []      t₁ t₂ h hl := list.no_confusion $ eq_nil_of_length_eq_zero hl
| []      (b::s₂) t₁ t₂ h hl := list.no_confusion $ eq_nil_of_length_eq_zero hl.symm
| (a::s₁) (b::s₂) t₁ t₂ h hl := list.no_confusion h $ λab hap,
  let ⟨e1, e2⟩ := @append_inj s₁ s₂ t₁ t₂ hap (succ.inj hl) in
  by rw [ab, e1, e2]; exact ⟨rfl, rfl⟩

theorem append_inj_left {s₁ s₂ t₁ t₂ : list α} (h : s₁ ++ t₁ = s₂ ++ t₂) (hl : length s₁ = length s₂) : s₁ = s₂ :=
(append_inj h hl).left

theorem append_inj_right {s₁ s₂ t₁ t₂ : list α} (h : s₁ ++ t₁ = s₂ ++ t₂) (hl : length s₁ = length s₂) : t₁ = t₂ :=
(append_inj h hl).right

theorem append_inj' {s₁ s₂ t₁ t₂ : list α} (h : s₁ ++ t₁ = s₂ ++ t₂) (hl : length t₁ = length t₂) : s₁ = s₂ ∧ t₁ = t₂ :=
append_inj h $ @nat.add_right_cancel _ (length t₁) _ $
let hap := congr_arg length h in by simp at hap; rwa [← hl] at hap

theorem append_inj_left' {s₁ s₂ t₁ t₂ : list α} (h : s₁ ++ t₁ = s₂ ++ t₂) (hl : length t₁ = length t₂) : s₁ = s₂ :=
(append_inj' h hl).left

theorem append_inj_right' {s₁ s₂ t₁ t₂ : list α} (h : s₁ ++ t₁ = s₂ ++ t₂) (hl : length t₁ = length t₂) : t₁ = t₂ :=
(append_inj' h hl).right

theorem append_left_cancel {s₁ s₂ t : list α} (h : s₁ ++ t = s₂ ++ t) : s₁ = s₂ :=
append_inj_left' h rfl

theorem append_right_cancel {s t₁ t₂ : list α} (h : s ++ t₁ = s ++ t₂) : t₁ = t₂ :=
append_inj_right h rfl

theorem eq_of_mem_repeat {a b : α} : ∀ {n}, b ∈ repeat a n → b = a
| (n+1) h := or.elim h id $ @eq_of_mem_repeat _

theorem eq_repeat_of_mem {a : α} : ∀ {l : list α}, (∀ b ∈ l, b = a) → l = repeat a l.length
| [] H := rfl
| (b::l) H :=
  have b = a ∧ ∀ (x : α), x ∈ l → x = a,
  by simpa [or_imp_distrib, forall_and_distrib] using H,
  by dsimp; congr; [exact this.1, exact eq_repeat_of_mem this.2]

theorem eq_repeat' {a : α} {l : list α} : l = repeat a l.length ↔ ∀ b ∈ l, b = a :=
⟨λ h, h.symm ▸ λ b, eq_of_mem_repeat, eq_repeat_of_mem⟩

theorem eq_repeat {a : α} {n} {l : list α} : l = repeat a n ↔ length l = n ∧ ∀ b ∈ l, b = a :=
⟨λ h, h.symm ▸ ⟨length_repeat _ _, λ b, eq_of_mem_repeat⟩,
 λ ⟨e, al⟩, e ▸ eq_repeat_of_mem al⟩

theorem repeat_subset_singleton (a : α) (n) : repeat a n ⊆ [a] :=
λ b h, mem_singleton.2 (eq_of_mem_repeat h)

@[simp] theorem map_const (l : list α) (b : β) : map (function.const α b) l = repeat b l.length :=
by induction l; simp [-add_comm, *]

theorem eq_of_mem_map_const {b₁ b₂ : β} {l : list α} (h : b₁ ∈ map (function.const α b₂) l) : b₁ = b₂ :=
by rw map_const at h; exact eq_of_mem_repeat h

/- bind -/

@[simp] theorem bind_eq_bind {α β} (f : α → list β) (l : list α) :
  l >>= f = l.bind f := rfl

/- concat -/

/-- Concatenate an element at the end of a list. `concat [a, b] c = [a, b, c]` -/
@[simp] def concat : list α → α → list α
| []     a := [a]
| (b::l) a := b :: concat l a

@[simp] theorem concat_nil (a : α) : concat [] a = [a] := rfl

@[simp] theorem concat_cons (a b : α) (l : list α) : concat (a :: l) b  = a :: concat l b := rfl

@[simp] theorem concat_ne_nil (a : α) (l : list α) : concat l a ≠ [] :=
by induction l; intro h; contradiction

@[simp] theorem concat_append (a : α) (l₁ l₂ : list α) : concat l₁ a ++ l₂ = l₁ ++ a :: l₂ :=
by induction l₁ with b l₁ ih; [simp, simp [ih]]

@[simp] theorem concat_eq_append (a : α) (l : list α) : concat l a = l ++ [a] :=
by induction l; simp [*, concat]

@[simp] theorem length_concat (a : α) (l : list α) : length (concat l a) = succ (length l) :=
by simp [succ_eq_add_one]

theorem append_concat (a : α) (l₁ l₂ : list α) : l₁ ++ concat l₂ a = concat (l₁ ++ l₂) a :=
by induction l₂ with b l₂ ih; simp

/- reverse -/

@[simp] theorem reverse_nil : reverse (@nil α) = [] := rfl

local attribute [simp] reverse_core

@[simp] theorem reverse_cons (a : α) (l : list α) : reverse (a::l) = concat (reverse l) a :=
have aux : ∀ l₁ l₂, reverse_core l₁ (concat l₂ a) = concat (reverse_core l₁ l₂) a,
  by intros l₁; induction l₁; intros; rsimp,
aux l nil

theorem reverse_cons' (a : α) (l : list α) : reverse (a::l) = reverse l ++ [a] :=
by simp

@[simp] theorem reverse_singleton (a : α) : reverse [a] = [a] := rfl

@[simp] theorem reverse_append (s t : list α) : reverse (s ++ t) = (reverse t) ++ (reverse s) :=
by induction s; simp *

@[simp] theorem reverse_reverse (l : list α) : reverse (reverse l) = l :=
by induction l; simp *

theorem reverse_injective : injective (@reverse α) :=
injective_of_left_inverse reverse_reverse

@[simp] theorem reverse_inj {l₁ l₂ : list α} : reverse l₁ = reverse l₂ ↔ l₁ = l₂ :=
reverse_injective.eq_iff

@[simp] theorem reverse_eq_nil {l : list α} : reverse l = [] ↔ l = [] :=
@reverse_inj _ l []

theorem concat_eq_reverse_cons (a : α) (l : list α) : concat l a = reverse (a :: reverse l) :=
by simp

@[simp] theorem length_reverse (l : list α) : length (reverse l) = length l :=
by induction l; simp *

@[simp] theorem map_reverse (f : α → β) (l : list α) : map f (reverse l) = reverse (map f l) :=
by induction l; simp *

@[simp] theorem mem_reverse {a : α} {l : list α} : a ∈ reverse l ↔ a ∈ l :=
by induction l; simp [*, or_comm]

@[elab_as_eliminator] theorem reverse_rec_on {C : list α → Sort*}
  (l : list α) (H0 : C [])
  (H1 : ∀ (l : list α) (a : α), C l → C (l ++ [a])) : C l :=
begin
  rw ← reverse_reverse l,
  induction reverse l,
  { exact H0 },
  { simp, exact H1 _ _ ih }
end

/- last -/

@[simp] theorem last_cons {a : α} {l : list α} : ∀ (h₁ : a :: l ≠ nil) (h₂ : l ≠ nil), last (a :: l) h₁ = last l h₂ :=
by {induction l; intros, contradiction, simp *, reflexivity}

@[simp] theorem last_append {a : α} (l : list α) (h : l ++ [a] ≠ []) : last (l ++ [a]) h = a :=
begin
  induction l with hd tl ih; rsimp,
  have haux : tl ++ [a] ≠ [],
    {apply append_ne_nil_of_ne_nil_right, contradiction},
  simp *
end

theorem last_concat {a : α} (l : list α) (h : concat l a ≠ []) : last (concat l a) h = a :=
by simp *

@[simp] theorem last_singleton (a : α) (h : [a] ≠ []) : last [a] h = a := rfl

@[simp] theorem last_cons_cons (a₁ a₂ : α) (l : list α) (h : a₁::a₂::l ≠ []) :
  last (a₁::a₂::l) h = last (a₂::l) (cons_ne_nil a₂ l) := rfl

theorem last_congr {l₁ l₂ : list α} (h₁ : l₁ ≠ []) (h₂ : l₂ ≠ []) (h₃ : l₁ = l₂) :
  last l₁ h₁ = last l₂ h₂ :=
by subst l₁

/- head and tail -/

@[simp] theorem head_cons [h : inhabited α] (a : α) (l : list α) : head (a::l) = a := rfl

@[simp] theorem tail_nil : tail (@nil α) = [] := rfl

@[simp] theorem tail_cons (a : α) (l : list α) : tail (a::l) = l := rfl

@[simp] theorem head_append [h : inhabited α] (t : list α) {s : list α} (h : s ≠ []) : head (s ++ t) = head s :=
by {induction s, contradiction, simp}

theorem cons_head_tail [h : inhabited α] {l : list α} (h : l ≠ []) : (head l)::(tail l) = l :=
by {induction l, contradiction, simp}

/- map -/

lemma map_congr {f g : α → β} : ∀ {l : list α}, (∀ x ∈ l, f x = g x) → map f l = map g l
| [] _     := rfl
| (a::l) h :=
  have f a = g a, from h _ (mem_cons_self _ _),
  have map f l = map g l, from map_congr $ assume a', h _ ∘ mem_cons_of_mem _,
  show f a :: map f l = g a :: map g l, by simp [*]

theorem map_concat (f : α → β) (a : α) (l : list α) : map f (concat l a) = concat (map f l) (f a) :=
by induction l; simp *

theorem map_id' {f : α → α} (h : ∀ x, f x = x) (l : list α) : map f l = l :=
by induction l; simp *

@[simp] theorem foldl_map (g : β → γ) (f : α → γ → α) (a : α) (l : list β) : foldl f a (map g l) = foldl (λx y, f x (g y)) a l :=
by revert a; induction l; intros; simp *

@[simp] theorem foldr_map (g : β → γ) (f : γ → α → α) (a : α) (l : list β) : foldr f a (map g l) = foldr (f ∘ g) a l :=
by revert a; induction l; intros; simp *

theorem foldl_hom (f : α → β) (g : α → γ → α) (g' : β → γ → β) (a : α)
  (h : ∀a x, f (g a x) = g' (f a) x) (l : list γ) : f (foldl g a l) = foldl g' (f a) l :=
by revert a; induction l; intros; simp *

theorem foldr_hom (f : α → β) (g : γ → α → α) (g' : γ → β → β) (a : α)
  (h : ∀x a, f (g x a) = g' x (f a)) (l : list γ) : f (foldr g a l) = foldr g' (f a) l :=
by revert a; induction l; intros; simp *

theorem eq_nil_of_map_eq_nil {f : α → β} {l : list α} (h : map f l = nil) : l = nil :=
eq_nil_of_length_eq_zero (begin rw [← length_map f l], simp [h] end)

@[simp] theorem map_join (f : α → β) (L : list (list α)) :
  map f (join L) = join (map (map f) L) :=
by induction L; simp *

theorem bind_ret_eq_map {α β} (f : α → β) (l : list α) :
  l.bind (list.ret ∘ f) = map f l :=
by simp [list.bind]; induction l; simp [list.ret, join, *]

@[simp] theorem map_eq_map {α β} (f : α → β) (l : list α) :
  f <$> l = map f l := rfl

/- map₂ -/

theorem nil_map₂ (f : α → β → γ) (l : list β) : map₂ f [] l = [] :=
by cases l; refl

theorem map₂_nil (f : α → β → γ) (l : list α) : map₂ f l [] = [] :=
by cases l; refl

/- sublists -/

@[simp] theorem nil_sublist : Π (l : list α), [] <+ l
| []       := sublist.slnil
| (a :: l) := sublist.cons _ _ a (nil_sublist l)

@[refl, simp] theorem sublist.refl : Π (l : list α), l <+ l
| []       := sublist.slnil
| (a :: l) := sublist.cons2 _ _ a (sublist.refl l)

@[trans] theorem sublist.trans {l₁ l₂ l₃ : list α} (h₁ : l₁ <+ l₂) (h₂ : l₂ <+ l₃) : l₁ <+ l₃ :=
sublist.rec_on h₂ (λ_ s, s)
  (λl₂ l₃ a h₂ IH l₁ h₁, sublist.cons _ _ _ (IH l₁ h₁))
  (λl₂ l₃ a h₂ IH l₁ h₁, @sublist.cases_on _ (λl₁ l₂', l₂' = a :: l₂ → l₁ <+ a :: l₃) _ _ h₁
    (λ_, nil_sublist _)
    (λl₁ l₂' a' h₁' e, match a', l₂', e, h₁' with ._, ._, rfl, h₁ := sublist.cons _ _ _ (IH _ h₁) end)
    (λl₁ l₂' a' h₁' e, match a', l₂', e, h₁' with ._, ._, rfl, h₁ := sublist.cons2 _ _ _ (IH _ h₁) end) rfl)
  l₁ h₁

@[simp] theorem sublist_cons (a : α) (l : list α) : l <+ a::l :=
sublist.cons _ _ _ (sublist.refl l)

theorem sublist_of_cons_sublist {a : α} {l₁ l₂ : list α} : a::l₁ <+ l₂ → l₁ <+ l₂ :=
sublist.trans (sublist_cons a l₁)

theorem cons_sublist_cons {l₁ l₂ : list α} (a : α) (s : l₁ <+ l₂) : a::l₁ <+ a::l₂ :=
sublist.cons2 _ _ _ s

@[simp] theorem sublist_append_left : Π (l₁ l₂ : list α), l₁ <+ l₁++l₂
| []      l₂ := nil_sublist _
| (a::l₁) l₂ := cons_sublist_cons _ (sublist_append_left l₁ l₂)

@[simp] theorem sublist_append_right : Π (l₁ l₂ : list α), l₂ <+ l₁++l₂
| []      l₂ := sublist.refl _
| (a::l₁) l₂ := sublist.cons _ _ _ (sublist_append_right l₁ l₂)

theorem sublist_cons_of_sublist (a : α) {l₁ l₂ : list α} : l₁ <+ l₂ → l₁ <+ a::l₂ :=
sublist.cons _ _ _

theorem sublist_app_of_sublist_left {l l₁ l₂ : list α} (s : l <+ l₁) : l <+ l₁++l₂ :=
s.trans $ sublist_append_left _ _

theorem sublist_app_of_sublist_right {l l₁ l₂ : list α} (s : l <+ l₂) : l <+ l₁++l₂ :=
s.trans $ sublist_append_right _ _

theorem sublist_of_cons_sublist_cons {l₁ l₂ : list α} : ∀ {a : α}, a::l₁ <+ a::l₂ → l₁ <+ l₂
| ._ (sublist.cons  ._ ._ a s) := sublist_of_cons_sublist s
| ._ (sublist.cons2 ._ ._ a s) := s

theorem cons_sublist_cons_iff {l₁ l₂ : list α} {a : α} : a::l₁ <+ a::l₂ ↔ l₁ <+ l₂ :=
⟨sublist_of_cons_sublist_cons, cons_sublist_cons _⟩

@[simp] theorem append_sublist_append_left {l₁ l₂ : list α} : ∀ l, l++l₁ <+ l++l₂ ↔ l₁ <+ l₂
| []     := iff.rfl
| (a::l) := cons_sublist_cons_iff.trans (append_sublist_append_left l)

theorem append_sublist_append_of_sublist_right {l₁ l₂ : list α} (h : l₁ <+ l₂) (l) : l₁++l <+ l₂++l :=
begin
  induction h with _ _ a _ ih _ _ a _ ih,
  { refl },
  { apply sublist_cons_of_sublist a ih },
  { apply cons_sublist_cons a ih }
end

theorem sublist_or_mem_of_sublist {l l₁ l₂ : list α} {a : α} (h : l <+ l₁ ++ a::l₂) : l <+ l₁ ++ l₂ ∨ a ∈ l :=
begin
  induction l₁ with b l₁ IH generalizing l,
  { cases h; simp * },
  { cases h with _ _ _ h _ _ _ h,
    { exact or.imp_left (sublist_cons_of_sublist _) (IH h) },
    { exact (IH h).imp (cons_sublist_cons _) (mem_cons_of_mem _) } }
end

theorem reverse_sublist {l₁ l₂ : list α} (h : l₁ <+ l₂) : l₁.reverse <+ l₂.reverse :=
begin
  induction h with _ _ _ _ ih _ _ a _ ih; simp,
  { exact sublist_app_of_sublist_left ih },
  { exact append_sublist_append_of_sublist_right ih [a] }
end

@[simp] theorem reverse_sublist_iff {l₁ l₂ : list α} : l₁.reverse <+ l₂.reverse ↔ l₁ <+ l₂ :=
⟨λ h, by have := reverse_sublist h; simp at this; assumption, reverse_sublist⟩

@[simp] theorem append_sublist_append_right {l₁ l₂ : list α} (l) : l₁++l <+ l₂++l ↔ l₁ <+ l₂ :=
⟨λ h, by have := reverse_sublist h; simp at this; assumption,
 λ h, append_sublist_append_of_sublist_right h l⟩

theorem subset_of_sublist : Π {l₁ l₂ : list α}, l₁ <+ l₂ → l₁ ⊆ l₂
| ._ ._ sublist.slnil             b h := h
| ._ ._ (sublist.cons  l₁ l₂ a s) b h := mem_cons_of_mem _ (subset_of_sublist s h)
| ._ ._ (sublist.cons2 l₁ l₂ a s) b h :=
  match eq_or_mem_of_mem_cons h with
  | or.inl h := h ▸ mem_cons_self _ _
  | or.inr h := mem_cons_of_mem _ (subset_of_sublist s h)
  end

theorem singleton_sublist {a : α} {l} : [a] <+ l ↔ a ∈ l :=
⟨λ h, subset_of_sublist h (mem_singleton_self _), λ h,
let ⟨s, t, e⟩ := mem_split h in e.symm ▸
  (cons_sublist_cons _ (nil_sublist _)).trans (sublist_append_right _ _)⟩

theorem eq_nil_of_sublist_nil {l : list α} (s : l <+ []) : l = [] :=
eq_nil_of_subset_nil $ subset_of_sublist s

theorem repeat_sublist_repeat (a : α) {m n} : repeat a m <+ repeat a n ↔ m ≤ n :=
⟨λ h, by simpa using length_le_of_sublist h,
 λ h, by induction h; [apply sublist.refl, simp [*, sublist.cons]] ⟩

theorem eq_of_sublist_of_length_eq : ∀ {l₁ l₂ : list α}, l₁ <+ l₂ → length l₁ = length l₂ → l₁ = l₂
| ._ ._ sublist.slnil             h := rfl
| ._ ._ (sublist.cons  l₁ l₂ a s) h :=
  absurd (length_le_of_sublist s) $ not_le_of_gt $ by rw h; apply lt_succ_self
| ._ ._ (sublist.cons2 l₁ l₂ a s) h :=
  by rw [length, length] at h; injection h with h; rw eq_of_sublist_of_length_eq s h

theorem eq_of_sublist_of_length_le {l₁ l₂ : list α} (s : l₁ <+ l₂) (h : length l₂ ≤ length l₁) : l₁ = l₂ :=
eq_of_sublist_of_length_eq s (le_antisymm (length_le_of_sublist s) h)

theorem sublist_antisymm {l₁ l₂ : list α} (s₁ : l₁ <+ l₂) (s₂ : l₂ <+ l₁) : l₁ = l₂ :=
eq_of_sublist_of_length_le s₁ (length_le_of_sublist s₂)

instance decidable_sublist [decidable_eq α] : ∀ (l₁ l₂ : list α), decidable (l₁ <+ l₂)
| []      l₂      := is_true $ nil_sublist _
| (a::l₁) []      := is_false $ λh, list.no_confusion $ eq_nil_of_sublist_nil h
| (a::l₁) (b::l₂) :=
  if h : a = b then
    decidable_of_decidable_of_iff (decidable_sublist l₁ l₂) $
      by rw [← h]; exact ⟨cons_sublist_cons _, sublist_of_cons_sublist_cons⟩
  else decidable_of_decidable_of_iff (decidable_sublist (a::l₁) l₂)
    ⟨sublist_cons_of_sublist _, λs, match a, l₁, s, h with
    | a, l₁, sublist.cons ._ ._ ._ s', h := s'
    | ._, ._, sublist.cons2 t ._ ._ s', h := absurd rfl h
    end⟩

/- index_of -/

section index_of
variable [decidable_eq α]

@[simp] theorem index_of_nil (a : α) : index_of a [] = 0 := rfl

theorem index_of_cons (a b : α) (l : list α) : index_of a (b::l) = if a = b then 0 else succ (index_of a l) := rfl

theorem index_of_cons_eq {a b : α} (l : list α) : a = b → index_of a (b::l) = 0 :=
assume e, if_pos e

@[simp] theorem index_of_cons_self (a : α) (l : list α) : index_of a (a::l) = 0 :=
index_of_cons_eq _ rfl

@[simp] theorem index_of_cons_ne {a b : α} (l : list α) : a ≠ b → index_of a (b::l) = succ (index_of a l) :=
assume n, if_neg n

theorem index_of_eq_length {a : α} {l : list α} : index_of a l = length l ↔ a ∉ l :=
begin
  induction l with b l ih; simp [-add_comm],
  by_cases h : a = b; simp [h, -add_comm],
  { intro, contradiction },
  { rw ← ih, exact ⟨succ_inj, congr_arg _⟩ }
end

@[simp] theorem index_of_of_not_mem {l : list α} {a : α} : a ∉ l → index_of a l = length l :=
index_of_eq_length.2

theorem index_of_le_length {a : α} {l : list α} : index_of a l ≤ length l :=
begin
  induction l with b l ih; simp [-add_comm, index_of_cons],
  by_cases h : a = b; simp [h, -add_comm, zero_le],
  exact succ_le_succ ih
end

theorem index_of_lt_length {a} {l : list α} : index_of a l < length l ↔ a ∈ l :=
⟨λh, by_contradiction $ λ al, ne_of_lt h $ index_of_eq_length.2 al,
λal, lt_of_le_of_ne index_of_le_length $ λ h, index_of_eq_length.1 h al⟩

end index_of

/- nth element -/

theorem nth_le_of_mem : ∀ {a} {l : list α}, a ∈ l → ∃ n h, nth_le l n h = a
| a (_ :: l) (or.inl rfl) := ⟨0, succ_pos _, rfl⟩
| a (b :: l) (or.inr m)   :=
  let ⟨n, h, e⟩ := nth_le_of_mem m in ⟨n+1, succ_lt_succ h, e⟩

theorem nth_le_nth : ∀ {l : list α} {n} h, nth l n = some (nth_le l n h)
| (a :: l) 0     h := rfl
| (a :: l) (n+1) h := @nth_le_nth l n _

theorem nth_ge_len : ∀ {l : list α} {n}, n ≥ length l → nth l n = none
| []       n     h := rfl
| (a :: l) (n+1) h := nth_ge_len (le_of_succ_le_succ h)

theorem nth_eq_some {l : list α} {n a} : nth l n = some a ↔ ∃ h, nth_le l n h = a :=
⟨λ e,
  have h : n < length l, from lt_of_not_ge $ λ hn,
    by rw nth_ge_len hn at e; contradiction,
  ⟨h, by rw nth_le_nth h at e;
    injection e with e; apply nth_le_mem⟩,
λ ⟨h, e⟩, e ▸ nth_le_nth _⟩

theorem nth_of_mem {a} {l : list α} (h : a ∈ l) : ∃ n, nth l n = some a :=
let ⟨n, h, e⟩ := nth_le_of_mem h in ⟨n, by rw [nth_le_nth, e]⟩

theorem nth_le_mem : ∀ (l : list α) n h, nth_le l n h ∈ l
| (a :: l) 0     h := mem_cons_self _ _
| (a :: l) (n+1) h := mem_cons_of_mem _ (nth_le_mem l _ _)

theorem nth_mem {l : list α} {n a} (e : nth l n = some a) : a ∈ l :=
let ⟨h, e⟩ := nth_eq_some.1 e in e ▸ nth_le_mem _ _ _

theorem mem_iff_nth_le {a} {l : list α} : a ∈ l ↔ ∃ n h, nth_le l n h = a :=
⟨nth_le_of_mem, λ ⟨n, h, e⟩, e ▸ nth_le_mem _ _ _⟩

theorem mem_iff_nth {a} {l : list α} : a ∈ l ↔ ∃ n, nth l n = some a :=
mem_iff_nth_le.trans $ exists_congr $ λ n, nth_eq_some.symm

theorem ext : ∀ {l₁ l₂ : list α}, (∀n, nth l₁ n = nth l₂ n) → l₁ = l₂
| []      []       h := rfl
| (a::l₁) []       h := by have h0 := h 0; contradiction
| []      (a'::l₂) h := by have h0 := h 0; contradiction
| (a::l₁) (a'::l₂) h := by have h0 : some a = some a' := h 0; injection h0 with aa; simp [*, ext (λn, h (n+1))]

theorem ext_le {l₁ l₂ : list α} (hl : length l₁ = length l₂) (h : ∀n h₁ h₂, nth_le l₁ n h₁ = nth_le l₂ n h₂) : l₁ = l₂ :=
ext $ λn, if h₁ : n < length l₁
  then by rw [nth_le_nth, nth_le_nth, h n h₁ (by rwa [← hl])]
  else let h₁ := le_of_not_gt h₁ in by rw [nth_ge_len h₁, nth_ge_len (by rwa [← hl])]

@[simp] theorem index_of_nth_le [decidable_eq α] {a : α} : ∀ {l : list α} h, nth_le l (index_of a l) h = a
| (b::l) h := by by_cases h' : a = b; simp *

@[simp] theorem index_of_nth [decidable_eq α] {a : α} {l : list α} (h : a ∈ l) : nth l (index_of a l) = some a :=
by rw [nth_le_nth, index_of_nth_le (index_of_lt_length.2 h)]

theorem nth_le_reverse_aux1 : ∀ (l r : list α) (i h1 h2), nth_le (reverse_core l r) (i + length l) h1 = nth_le r i h2
| []       r i := λh1 h2, rfl
| (a :: l) r i := by rw (show i + length (a :: l) = i + 1 + length l, by simp); exact
  λh1 h2, nth_le_reverse_aux1 l (a :: r) (i+1) h1 (succ_lt_succ h2)

theorem nth_le_reverse_aux2 : ∀ (l r : list α) (i : nat) (h1) (h2),
  nth_le (reverse_core l r) (length l - 1 - i) h1 = nth_le l i h2
| []       r i     h1 h2 := absurd h2 (not_lt_zero _)
| (a :: l) r 0     h1 h2 := begin
    have aux := nth_le_reverse_aux1 l (a :: r) 0,
    rw zero_add at aux,
    exact aux _ (zero_lt_succ _)
  end
| (a :: l) r (i+1) h1 h2 := begin
    have aux := nth_le_reverse_aux2 l (a :: r) i,
    have heq := calc length (a :: l) - 1 - (i + 1)
          = length l - (1 + i) : by rw add_comm; refl
      ... = length l - 1 - i   : by rw nat.sub_sub,
    rw [← heq] at aux,
    apply aux
  end

@[simp] theorem nth_le_reverse (l : list α) (i : nat) (h1 h2) :
  nth_le (reverse l) (length l - 1 - i) h1 = nth_le l i h2 :=
nth_le_reverse_aux2 _ _ _ _ _

/-- Convert a list into an array (whose length is the length of `l`) -/
def to_array (l : list α) : array l.length α :=
{data := λ v, l.nth_le v.1 v.2}

/-- "inhabited" `nth` function: returns `default` instead of `none` in the case
  that the index is out of bounds. -/
@[simp] def inth [h : inhabited α] (l : list α) (n : nat) : α := (nth l n).iget

/- nth tail operation -/

/-- Apply a function to the nth tail of `l`.
  `modify_nth_tail f 2 [a, b, c] = [a, b] ++ f [c]`. Returns the input without
  using `f` if the index is larger than the length of the list. -/
@[simp] def modify_nth_tail (f : list α → list α) : ℕ → list α → list α
| 0     l      := f l
| (n+1) []     := []
| (n+1) (a::l) := a :: modify_nth_tail n l

/-- Apply `f` to the head of the list, if it exists. -/
@[simp] def modify_head (f : α → α) : list α → list α
| []     := []
| (a::l) := f a :: l

/-- Apply `f` to the nth element of the list, if it exists. -/
def modify_nth (f : α → α) : ℕ → list α → list α :=
modify_nth_tail (modify_head f)

theorem remove_nth_eq_nth_tail : ∀ n (l : list α), remove_nth l n = modify_nth_tail tail n l
| 0     l      := by cases l; refl
| (n+1) []     := rfl
| (n+1) (a::l) := congr_arg (cons _) (remove_nth_eq_nth_tail _ _)

theorem update_nth_eq_modify_nth (a : α) : ∀ n (l : list α),
  update_nth l n a = modify_nth (λ _, a) n l
| 0     l      := by cases l; refl
| (n+1) []     := rfl
| (n+1) (b::l) := congr_arg (cons _) (update_nth_eq_modify_nth _ _)

theorem modify_nth_eq_update_nth (f : α → α) : ∀ n (l : list α),
  modify_nth f n l = ((λ a, update_nth l n (f a)) <$> nth l n).get_or_else l
| 0     l      := by cases l; refl
| (n+1) []     := rfl
| (n+1) (b::l) := (congr_arg (cons b)
  (modify_nth_eq_update_nth n l)).trans $ by cases nth l n; refl

theorem nth_modify_nth (f : α → α) : ∀ n (l : list α) m,
  nth (modify_nth f n l) m = (λ a, if n = m then f a else a) <$> nth l m
| n     l      0     := by cases l; cases n; refl
| n     []     (m+1) := by cases n; refl
| 0     (a::l) (m+1) := by cases nth l m; refl
| (n+1) (a::l) (m+1) := (nth_modify_nth n l m).trans $
  by cases nth l m with b; by_cases n = m; simp [h, mt succ_inj]

theorem modify_nth_tail_length (f : list α → list α) (H : ∀ l, length (f l) = length l) :
  ∀ n l, length (modify_nth_tail f n l) = length l
| 0     l      := H _
| (n+1) []     := rfl
| (n+1) (a::l) := @congr_arg _ _ _ _ (+1) (modify_nth_tail_length _ _)

@[simp] theorem modify_nth_length (f : α → α) :
  ∀ n l, length (modify_nth f n l) = length l :=
modify_nth_tail_length _ (λ l, by cases l; refl)

@[simp] theorem update_nth_length (l : list α) (n) (a : α) :
  length (update_nth l n a) = length l :=
by simp [update_nth_eq_modify_nth]

@[simp] theorem nth_modify_nth_eq (f : α → α) (n) (l : list α) :
  nth (modify_nth f n l) n = f <$> nth l n :=
by simp [nth_modify_nth]

@[simp] theorem nth_modify_nth_ne (f : α → α) {m n} (l : list α) (h : m ≠ n) :
  nth (modify_nth f m l) n = nth l n :=
by simp [nth_modify_nth, h]; cases nth l n; refl

theorem nth_update_nth_eq (a : α) (n) (l : list α) :
  nth (update_nth l n a) n = (λ _, a) <$> nth l n :=
by simp [update_nth_eq_modify_nth]

theorem nth_update_nth_of_lt (a : α) {n} {l : list α} (h : n < length l) :
  nth (update_nth l n a) n = some a :=
by rw [nth_update_nth_eq, nth_le_nth h]; refl

theorem nth_update_nth_ne (a : α) {m n} (l : list α) (h : m ≠ n) :
  nth (update_nth l m a) n = nth l n :=
by simp [update_nth_eq_modify_nth, h]

/- take, drop -/
@[simp] theorem take_zero : ∀ (l : list α), take 0 l = [] :=
begin intros, reflexivity end

@[simp] theorem take_nil : ∀ n, take n [] = ([] : list α)
| 0     := rfl
| (n+1) := rfl

theorem take_cons (n) (a : α) (l : list α) : take (succ n) (a::l) = a :: take n l := rfl

theorem take_all : ∀ (l : list α), take (length l) l = l
| []     := rfl
| (a::l) := begin change a :: (take (length l) l) = a :: l, rw take_all end

theorem take_all_of_ge : ∀ {n} {l : list α}, n ≥ length l → take n l = l
| 0     []     h := rfl
| 0     (a::l) h := absurd h (not_le_of_gt (zero_lt_succ _))
| (n+1) []     h := rfl
| (n+1) (a::l) h :=
  begin
    change a :: take n l = a :: l,
    rw [take_all_of_ge (le_of_succ_le_succ h)]
  end

theorem take_take : ∀ (n m) (l : list α), take n (take m l) = take (min n m) l
| n         0        l      := by rw [min_zero, take_zero, take_nil]
| 0         m        l      := by simp
| (succ n)  (succ m) nil    := by simp
| (succ n)  (succ m) (a::l) := by simp [min_succ_succ, take_take]

theorem drop_eq_nth_le_cons : ∀ {n} {l : list α} h,
  drop n l = nth_le l n h :: drop (n+1) l
| 0     (a::l) h := rfl
| (n+1) (a::l) h := @drop_eq_nth_le_cons n _ _

theorem modify_nth_tail_eq_take_drop (f : list α → list α) (H : f [] = []) :
  ∀ n l, modify_nth_tail f n l = take n l ++ f (drop n l)
| 0     l      := rfl
| (n+1) []     := H.symm
| (n+1) (b::l) := congr_arg (cons b) (modify_nth_tail_eq_take_drop n l)

theorem modify_nth_eq_take_drop (f : α → α) :
  ∀ n l, modify_nth f n l = take n l ++ modify_head f (drop n l) :=
modify_nth_tail_eq_take_drop _ rfl

theorem modify_nth_eq_take_cons_drop (f : α → α) {n l} (h) :
  modify_nth f n l = take n l ++ f (nth_le l n h) :: drop (n+1) l :=
by rw [modify_nth_eq_take_drop, drop_eq_nth_le_cons h]; refl

theorem update_nth_eq_take_cons_drop (a : α) {n l} (h : n < length l) :
  update_nth l n a = take n l ++ a :: drop (n+1) l :=
by rw [update_nth_eq_modify_nth, modify_nth_eq_take_cons_drop _ h]

@[simp] lemma update_nth_eq_nil (l : list α) (n : ℕ) (a : α) : l.update_nth n a = [] ↔ l = [] :=
by cases l; cases n; simp [update_nth]

/- take_while -/

/-- Get the longest initial segment of the list whose members all satisfy `p`.
  `take_while (λ x, x < 3) [0, 2, 5, 1] = [0, 2]` -/
def take_while (p : α → Prop) [decidable_pred p] : list α → list α
| []     := []
| (a::l) := if p a then a :: take_while l else []

/- foldl, foldr, scanl, scanr -/

@[simp] theorem foldl_nil (f : α → β → α) (a : α) : foldl f a [] = a := rfl

@[simp] theorem foldl_cons (f : α → β → α) (a : α) (b : β) (l : list β) :
  foldl f a (b::l) = foldl f (f a b) l := rfl

@[simp] theorem foldr_nil (f : α → β → β) (b : β) : foldr f b [] = b := rfl

@[simp] theorem foldr_cons (f : α → β → β) (b : β) (a : α) (l : list α) :
  foldr f b (a::l) = f a (foldr f b l) := rfl

@[simp] theorem foldl_append (f : α → β → α) :
  ∀ (a : α) (l₁ l₂ : list β), foldl f a (l₁++l₂) = foldl f (foldl f a l₁) l₂
| a []      l₂ := rfl
| a (b::l₁) l₂ := by simp [foldl_append]

@[simp] theorem foldr_append (f : α → β → β) :
  ∀ (b : β) (l₁ l₂ : list α), foldr f b (l₁++l₂) = foldr f (foldr f b l₂) l₁
| b []      l₂ := rfl
| b (a::l₁) l₂ := by simp [foldr_append]

@[simp] theorem foldl_join (f : α → β → α) :
  ∀ (a : α) (L : list (list β)), foldl f a (join L) = foldl (foldl f) a L
| a []     := rfl
| a (l::L) := by simp [foldl_join]

@[simp] theorem foldr_join (f : α → β → β) :
  ∀ (b : β) (L : list (list α)), foldr f b (join L) = foldr (λ l b, foldr f b l) b L
| a []     := rfl
| a (l::L) := by simp [foldr_join]

theorem foldl_reverse (f : α → β → α) (a : α) (l : list β) : foldl f a (reverse l) = foldr (λx y, f y x) a l :=
by induction l; simp [*, foldr]

theorem foldr_reverse (f : α → β → β) (a : β) (l : list α) : foldr f a (reverse l) = foldl (λx y, f y x) a l :=
let t := foldl_reverse (λx y, f y x) a (reverse l) in
by rw reverse_reverse l at t; rwa t

@[simp] theorem foldr_eta : ∀ (l : list α), foldr cons [] l = l
| []     := rfl
| (x::l) := by simp [foldr_eta l]

/-- Fold a function `f` over the list from the left, returning the list
  of partial results. `scanl (+) 0 [1, 2, 3] = [0, 1, 3, 6]` -/
def scanl (f : α → β → α) : α → list β → list α
| a []     := [a]
| a (b::l) := a :: scanl (f a b) l

def scanr_aux (f : α → β → β) (b : β) : list α → β × list β
| []     := (b, [])
| (a::l) := let (b', l') := scanr_aux l in (f a b', b' :: l')

/-- Fold a function `f` over the list from the right, returning the list
  of partial results. `scanr (+) 0 [1, 2, 3] = [6, 5, 3, 0]` -/
def scanr (f : α → β → β) (b : β) (l : list α) : list β :=
let (b', l') := scanr_aux f b l in b' :: l'

@[simp] theorem scanr_nil (f : α → β → β) (b : β) : scanr f b [] = [b] := rfl

@[simp] theorem scanr_aux_cons (f : α → β → β) (b : β) : ∀ (a : α) (l : list α),
  scanr_aux f b (a::l) = (foldr f b (a::l), scanr f b l)
| a []     := rfl
| a (x::l) := let t := scanr_aux_cons x l in
  by simp [scanr, scanr_aux] at t; simp [scanr, scanr_aux, t]

@[simp] theorem scanr_cons (f : α → β → β) (b : β) (a : α) (l : list α) :
  scanr f b (a::l) = foldr f b (a::l) :: scanr f b l :=
by simp [scanr]

section foldl_eq_foldr
  -- foldl and foldr coincide when f is commutative and associative
  variables {f : α → α → α} (hcomm : commutative f) (hassoc : associative f)

  include hassoc
  theorem foldl1_eq_foldr1 : ∀ a b l, foldl f a (l++[b]) = foldr f b (a::l)
  | a b nil      := rfl
  | a b (c :: l) := by simp [foldl1_eq_foldr1 _ _ l]; rw hassoc

  include hcomm
  theorem foldl_eq_of_comm_of_assoc : ∀ a b l, foldl f a (b::l) = f b (foldl f a l)
  | a b  nil    := hcomm a b
  | a b  (c::l) := by simp;
    rw [← foldl_eq_of_comm_of_assoc, right_comm _ hcomm hassoc]; simp

  theorem foldl_eq_foldr : ∀ a l, foldl f a l = foldr f a l
  | a nil      := rfl
  | a (b :: l) :=
    by simp [foldl_eq_of_comm_of_assoc hcomm hassoc]; rw (foldl_eq_foldr a l)
end foldl_eq_foldr

section
variables {op : α → α → α} [ha : is_associative α op] [hc : is_commutative α op]
local notation a * b := op a b
local notation l <*> a := foldl op a l

include ha

lemma foldl_assoc : ∀ {l : list α} {a₁ a₂}, l <*> (a₁ * a₂) = a₁ * (l <*> a₂)
| [] a₁ a₂ := by simp
| (a :: l) a₁ a₂ :=
  calc a::l <*> (a₁ * a₂) = l <*> (a₁ * (a₂ * a)) : by simp [ha.assoc]
    ... = a₁ * (a::l <*> a₂) : by rw [foldl_assoc]; simp

lemma foldl_op_eq_op_foldr_assoc : ∀{l : list α} {a₁ a₂}, (l <*> a₁) * a₂ = a₁ * l.foldr (*) a₂
| [] a₁ a₂ := by simp
| (a :: l) a₁ a₂ := by simp [foldl_assoc, ha.assoc]; rw [foldl_op_eq_op_foldr_assoc]

include hc

lemma foldl_assoc_comm_cons {l : list α} {a₁ a₂} : (a₁ :: l) <*> a₂ = a₁ * (l <*> a₂) :=
by rw [foldl_cons, hc.comm, foldl_assoc]

end

/- sum -/

/-- Product of a list. `prod [a, b, c] = ((1 * a) * b) * c` -/
@[to_additive list.sum]
def prod [has_mul α] [has_one α] : list α → α := foldl (*) 1
attribute [to_additive list.sum.equations._eqn_1] list.prod.equations._eqn_1

section monoid
variables [monoid α] {l l₁ l₂ : list α} {a : α}

@[simp, to_additive list.sum_nil]
theorem prod_nil : ([] : list α).prod = 1 := rfl

@[simp, to_additive list.sum_cons]
theorem prod_cons : (a::l).prod = a * l.prod :=
calc (a::l).prod = foldl (*) (a * 1) l : by simp [list.prod]
  ... = _ : foldl_assoc

@[simp, to_additive list.sum_append]
theorem prod_append : (l₁ ++ l₂).prod = l₁.prod * l₂.prod :=
calc (l₁ ++ l₂).prod = foldl (*) (foldl (*) 1 l₁ * 1) l₂ : by simp [list.prod]
  ... = l₁.prod * l₂.prod : foldl_assoc

@[simp, to_additive list.sum_join]
theorem prod_join {l : list (list α)} : l.join.prod = (l.map list.prod).prod :=
by induction l; simp [list.join, *] at *

end monoid

@[simp] theorem sum_const_nat (m n : ℕ) : sum (list.repeat m n) = m * n :=
by induction n; simp [*, nat.mul_succ]

@[simp] theorem length_join (L : list (list α)) : length (join L) = sum (map length L) :=
by induction L; simp *

@[simp] theorem length_bind (l : list α) (f : α → list β) : length (list.bind l f) = sum (map (length ∘ f) l) :=
by rw [list.bind, length_join, map_map]

/- all & any, bounded quantifiers over lists -/

theorem forall_mem_nil (p : α → Prop) : ∀ x ∈ @nil α, p x :=
by simp

@[simp] theorem forall_mem_cons' {p : α → Prop} {a : α} {l : list α} :
  (∀ (x : α), x = a ∨ x ∈ l → p x) ↔ p a ∧ ∀ x ∈ l, p x :=
by simp [or_imp_distrib, forall_and_distrib]

theorem forall_mem_cons {p : α → Prop} {a : α} {l : list α} :
  (∀ x ∈ a :: l, p x) ↔ p a ∧ ∀ x ∈ l, p x :=
by simp

theorem forall_mem_of_forall_mem_cons {p : α → Prop} {a : α} {l : list α}
    (h : ∀ x ∈ a :: l, p x) :
  ∀ x ∈ l, p x :=
(forall_mem_cons.1 h).2

theorem not_exists_mem_nil (p : α → Prop) : ¬ ∃ x ∈ @nil α, p x :=
by simp

theorem exists_mem_cons_of {p : α → Prop} {a : α} (l : list α) (h : p a) :
  ∃ x ∈ a :: l, p x :=
bex.intro a (by simp) h

theorem exists_mem_cons_of_exists {p : α → Prop} {a : α} {l : list α} (h : ∃ x ∈ l, p x) :
  ∃ x ∈ a :: l, p x :=
bex.elim h (λ x xl px, bex.intro x (by simp [xl]) px)

theorem or_exists_of_exists_mem_cons {p : α → Prop} {a : α} {l : list α} (h : ∃ x ∈ a :: l, p x) :
  p a ∨ ∃ x ∈ l, p x :=
bex.elim h (λ x xal px,
  or.elim (eq_or_mem_of_mem_cons xal)
    (assume : x = a, begin rw ←this, simp [px] end)
    (assume : x ∈ l, or.inr (bex.intro x this px)))

@[simp] theorem exists_mem_cons_iff (p : α → Prop) (a : α) (l : list α) :
  (∃ x ∈ a :: l, p x) ↔ p a ∨ ∃ x ∈ l, p x :=
iff.intro or_exists_of_exists_mem_cons
  (assume h, or.elim h (exists_mem_cons_of l) exists_mem_cons_of_exists)

@[simp] theorem all_nil (p : α → bool) : all [] p = tt := rfl

@[simp] theorem all_cons (p : α → bool) (a : α) (l : list α) : all (a::l) p = (p a && all l p) := rfl

theorem all_iff_forall {p : α → bool} {l : list α} : all l p ↔ ∀ a ∈ l, p a :=
by induction l with a l; simp [forall_and_distrib, *]

theorem all_iff_forall_prop {p : α → Prop} [decidable_pred p]
  {l : list α} : all l (λ a, p a) ↔ ∀ a ∈ l, p a :=
by simp [all_iff_forall]

@[simp] theorem any_nil (p : α → bool) : any [] p = ff := rfl

@[simp] theorem any_cons (p : α → bool) (a : α) (l : list α) : any (a::l) p = (p a || any l p) := rfl

theorem any_iff_exists {p : α → bool} {l : list α} : any l p ↔ ∃ a ∈ l, p a :=
by induction l with a l; simp [or_and_distrib_right, exists_or_distrib, *]

theorem any_iff_exists_prop {p : α → Prop} [decidable_pred p]
  {l : list α} : any l (λ a, p a) ↔ ∃ a ∈ l, p a :=
by simp [any_iff_exists]

theorem any_of_mem {p : α → bool} {a : α} {l : list α} (h₁ : a ∈ l) (h₂ : p a) : any l p :=
any_iff_exists.2 ⟨_, h₁, h₂⟩

instance decidable_forall_mem {p : α → Prop} [decidable_pred p] (l : list α) :
  decidable (∀ x ∈ l, p x) :=
decidable_of_iff _ all_iff_forall_prop

instance decidable_exists_mem {p : α → Prop} [decidable_pred p] (l : list α) :
  decidable (∃ x ∈ l, p x) :=
decidable_of_iff _ any_iff_exists_prop

/- map for partial functions -/

/-- Partial map. If `f : Π a, p a → β` is a partial function defined on
  `a : α` satisfying `p`, then `pmap f l h` is essentially the same as `map f l`
  but is defined only when all members of `l` satisfy `p`, using the proof
  to apply `f`. -/
@[simp] def pmap {p : α → Prop} (f : Π a, p a → β) : Π l : list α, (∀ a ∈ l, p a) → list β
| []     H := []
| (a::l) H := f a (forall_mem_cons.1 H).1 :: pmap l (forall_mem_cons.1 H).2

/-- "Attach" the proof that the elements of `l` are in `l` to produce a new list
  with the same elements but in the type `{x // x ∈ l}`. -/
def attach (l : list α) : list {x // x ∈ l} := pmap subtype.mk l (λ a, id)

theorem pmap_eq_map (p : α → Prop) (f : α → β) (l : list α) (H) :
  @pmap _ _ p (λ a _, f a) l H = map f l :=
by induction l; simp *

theorem pmap_congr {p q : α → Prop} {f : Π a, p a → β} {g : Π a, q a → β}
  (l : list α) {H₁ H₂} (h : ∀ a h₁ h₂, f a h₁ = g a h₂) :
  pmap f l H₁ = pmap g l H₂ :=
by induction l with _ _ ih; simp *; apply ih

theorem map_pmap {p : α → Prop} (g : β → γ) (f : Π a, p a → β)
  (l H) : map g (pmap f l H) = pmap (λ a h, g (f a h)) l H :=
by induction l; simp *

theorem pmap_eq_map_attach {p : α → Prop} (f : Π a, p a → β)
  (l H) : pmap f l H = l.attach.map (λ x, f x.1 (H _ x.2)) :=
by rw [attach, map_pmap]; exact pmap_congr l (λ a h₁ h₂, rfl)

theorem attach_map_val (l : list α) : l.attach.map subtype.val = l :=
by rw [attach, map_pmap]; exact (pmap_eq_map _ _ _ _).trans (map_id l)

@[simp] theorem mem_attach (l : list α) : ∀ x, x ∈ l.attach | ⟨a, h⟩ :=
by have := mem_map.1 (by rw [attach_map_val]; exact h);
   { rcases this with ⟨a, m, rfl⟩, cases a, exact m }

@[simp] theorem mem_pmap {p : α → Prop} {f : Π a, p a → β}
  {l H b} : b ∈ pmap f l H ↔ ∃ a (h : a ∈ l), f a (H a h) = b :=
by simp [pmap_eq_map_attach]

@[simp] theorem length_pmap {p : α → Prop} {f : Π a, p a → β}
  {l H} : length (pmap f l H) = length l :=
by induction l; simp *

/- find -/

section find
variables (p : α → Prop) [decidable_pred p]

/-- `find p l` is the first element of `l` satisfying `p`, or `none` if no such
  element exists. -/
def find : list α → option α
| []     := none
| (a::l) := if p a then some a else find l

def find_indexes_aux (p : α → Prop) [decidable_pred p] : list α → nat → list nat
| []     n := []
| (a::l) n := let t := find_indexes_aux l (succ n) in if p a then n :: t else t

/-- `find_indexes p l` is the list of indexes of elements of `l` that satisfy `p`. -/
def find_indexes (p : α → Prop) [decidable_pred p] (l : list α) : list nat :=
find_indexes_aux p l 0

@[simp] theorem find_nil : find p [] = none := rfl

@[simp] theorem find_cons_of_pos {p : α → Prop} [h : decidable_pred p] {a : α}
  (l) (h : p a) : find p (a::l) = some a :=
if_pos h

@[simp] theorem find_cons_of_neg {p : α → Prop} [h : decidable_pred p] {a : α}
  (l) (h : ¬ p a) : find p (a::l) = find p l :=
if_neg h

@[simp] theorem find_eq_none {p : α → Prop} [h : decidable_pred p] {l : list α} :
  find p l = none ↔ ∀ x ∈ l, ¬ p x :=
begin
  induction l with a l IH, {simp},
  by_cases p a; simp [h, IH]
end

@[simp] theorem find_some {p : α → Prop} [h : decidable_pred p] {l : list α} {a : α}
  (H : find p l = some a) : p a :=
begin
  induction l with b l IH, {contradiction},
  by_cases p b; simp [h] at H,
  { subst b, assumption },
  { exact IH H }
end

@[simp] theorem find_mem {p : α → Prop} [h : decidable_pred p] {l : list α} {a : α}
  (H : find p l = some a) : a ∈ l :=
begin
  induction l with b l IH, {contradiction},
  by_cases p b; simp [h] at H,
  { subst b, apply mem_cons_self },
  { exact mem_cons_of_mem _ (IH H) }
end

end find

/-- `indexes_of a l` is the list of all indexes of `a` in `l`.
  `indexes_of a [a, b, a, a] = [0, 2, 3]` -/
def indexes_of [decidable_eq α] (a : α) : list α → list nat := find_indexes (eq a)

/- filter_map -/

@[simp] theorem filter_map_nil (f : α → option β) : filter_map f [] = [] := rfl

@[simp] theorem filter_map_cons_none {f : α → option β} (a : α) (l : list α) (h : f a = none) :
  filter_map f (a :: l) = filter_map f l :=
by simp [filter_map, h]

@[simp] theorem filter_map_cons_some (f : α → option β)
  (a : α) (l : list α) {b : β} (h : f a = some b) :
  filter_map f (a :: l) = b :: filter_map f l :=
by simp [filter_map, h]

theorem filter_map_eq_map (f : α → β) : filter_map (some ∘ f) = map f :=
begin
  funext l,
  induction l with a l IH, {simp},
  simp [filter_map_cons_some (some ∘ f) _ _ rfl, IH]
end

theorem filter_map_eq_filter (p : α → Prop) [decidable_pred p] :
  filter_map (option.guard p) = filter p :=
begin
  funext l,
  induction l with a l IH, {simp},
  by_cases pa : p a; simp [filter_map, option.guard, pa, IH]
end

theorem filter_map_filter_map (f : α → option β) (g : β → option γ) (l : list α) :
  filter_map g (filter_map f l) = filter_map (λ x, (f x).bind g) l :=
begin
  induction l with a l IH, {refl},
  cases h : f a with b,
  { rw [filter_map_cons_none _ _ h, filter_map_cons_none, IH],
    simp [h, option.bind] },
  rw filter_map_cons_some _ _ _ h,
  cases h' : g b with c;
  [ rw [filter_map_cons_none _ _ h', filter_map_cons_none, IH],
    rw [filter_map_cons_some _ _ _ h', filter_map_cons_some, IH] ];
  simp [h, h', option.bind]
end

theorem map_filter_map (f : α → option β) (g : β → γ) (l : list α) :
  map g (filter_map f l) = filter_map (λ x, (f x).map g) l :=
by rw [← filter_map_eq_map, filter_map_filter_map]; refl

theorem filter_map_map (f : α → β) (g : β → option γ) (l : list α) :
  filter_map g (map f l) = filter_map (g ∘ f) l :=
by rw [← filter_map_eq_map, filter_map_filter_map]; refl

theorem filter_filter_map (f : α → option β) (p : β → Prop) [decidable_pred p] (l : list α) :
  filter p (filter_map f l) = filter_map (λ x, (f x).filter p) l :=
by rw [← filter_map_eq_filter, filter_map_filter_map]; refl

theorem filter_map_filter (p : α → Prop) [decidable_pred p] (f : α → option β) (l : list α) :
  filter_map f (filter p l) = filter_map (λ x, if p x then f x else none) l :=
begin
  rw [← filter_map_eq_filter, filter_map_filter_map], congr,
  funext x,
  show (option.guard p x).bind f = ite (p x) (f x) none,
  by_cases p x; simp [h, option.guard, option.bind]
end

@[simp] theorem filter_map_some (l : list α) : filter_map some l = l :=
by rw filter_map_eq_map; apply map_id

@[simp] theorem mem_filter_map (f : α → option β) (l : list α) {b : β} :
  b ∈ filter_map f l ↔ ∃ a, a ∈ l ∧ f a = some b :=
begin
  induction l with a l IH, {simp},
  cases h : f a with b',
  { have : f a ≠ some b, {rw h, intro, contradiction},
    simp [filter_map_cons_none _ _ h, IH,
          or_and_distrib_right, exists_or_distrib, this] },
  { have : f a = some b ↔ b = b',
    { split; intro t, {rw t at h; injection h}, {exact t.symm ▸ h} },
    simp [filter_map_cons_some _ _ _ h, IH,
          or_and_distrib_right, exists_or_distrib, this] }
end

theorem map_filter_map_of_inv (f : α → option β) (g : β → α)
  (H : ∀ x : α, (f x).map g = some x) (l : list α) :
  map g (filter_map f l) = l :=
by simp [map_filter_map, H]

theorem filter_map_sublist_filter_map (f : α → option β) {l₁ l₂ : list α}
  (s : l₁ <+ l₂) : filter_map f l₁ <+ filter_map f l₂ :=
by induction s with l₁ l₂ a s IH l₁ l₂ a s IH;
   simp [filter_map]; cases f a with b;
   simp [filter_map, IH, sublist.cons, sublist.cons2]

theorem map_sublist_map (f : α → β) {l₁ l₂ : list α}
  (s : l₁ <+ l₂) : map f l₁ <+ map f l₂ :=
by rw ← filter_map_eq_map; exact filter_map_sublist_filter_map _ s

/- filter -/

section filter
variables {p : α → Prop} [decidable_pred p]

@[simp] theorem filter_subset (l : list α) : filter p l ⊆ l :=
subset_of_sublist $ filter_sublist l

theorem of_mem_filter {a : α} : ∀ {l}, a ∈ filter p l → p a
| []     ain := absurd ain (not_mem_nil a)
| (b::l) ain :=
  if pb : p b then
    have a ∈ b :: filter p l, begin simp [pb] at ain, assumption end,
    or.elim (eq_or_mem_of_mem_cons this)
      (assume : a = b, begin rw [← this] at pb, exact pb end)
      (assume : a ∈ filter p l, of_mem_filter this)
  else
    begin simp [pb] at ain, exact (of_mem_filter ain) end

theorem mem_of_mem_filter {a : α} {l} (h : a ∈ filter p l) : a ∈ l :=
filter_subset l h

theorem mem_filter_of_mem {a : α} : ∀ {l}, a ∈ l → p a → a ∈ filter p l
| []     ain pa := absurd ain (not_mem_nil a)
| (b::l) ain pa :=
  if pb : p b then
    or.elim (eq_or_mem_of_mem_cons ain)
      (assume : a = b, by simp [pb, this])
      (assume : a ∈ l, begin simp [pb], exact (mem_cons_of_mem _ (mem_filter_of_mem this pa)) end)
  else
    or.elim (eq_or_mem_of_mem_cons ain)
      (assume : a = b, begin simp [this] at pa, contradiction end) --absurd (this ▸ pa) pb)
      (assume : a ∈ l, by simp [pa, pb, mem_filter_of_mem this])

@[simp] theorem mem_filter {a : α} {l} : a ∈ filter p l ↔ a ∈ l ∧ p a :=
⟨λ h, ⟨mem_of_mem_filter h, of_mem_filter h⟩, λ ⟨h₁, h₂⟩, mem_filter_of_mem h₁ h₂⟩

theorem filter_eq_self {l} : filter p l = l ↔ ∀ a ∈ l, p a :=
begin
  induction l with a l, {simp},
  by_cases p a; simp [filter, *],
  show filter p l ≠ a :: l, intro e,
  have := filter_sublist l, rw e at this,
  exact not_lt_of_ge (length_le_of_sublist this) (lt_succ_self _)
end

theorem filter_eq_nil {l} : filter p l = [] ↔ ∀ a ∈ l, ¬p a :=
by simp [-and.comm, eq_nil_iff_forall_not_mem, mem_filter]

theorem filter_sublist_filter {l₁ l₂} (s : l₁ <+ l₂) : filter p l₁ <+ filter p l₂ :=
by rw ← filter_map_eq_filter; exact filter_map_sublist_filter_map _ s

@[simp] theorem span_eq_take_drop (p : α → Prop) [decidable_pred p] : ∀ (l : list α), span p l = (take_while p l, drop_while p l)
| []     := rfl
| (a::l) := by by_cases pa : p a; simp [span, take_while, drop_while, pa, span_eq_take_drop l]

@[simp] theorem take_while_append_drop (p : α → Prop) [decidable_pred p] : ∀ (l : list α), take_while p l ++ drop_while p l = l
| []     := rfl
| (a::l) := by by_cases pa : p a; simp [take_while, drop_while, pa, take_while_append_drop l]

/-- `countp p l` is the number of elements of `l` that satisfy `p`. -/
def countp (p : α → Prop) [decidable_pred p] : list α → nat
| []      := 0
| (x::xs) := if p x then succ (countp xs) else countp xs

@[simp] theorem countp_nil (p : α → Prop) [decidable_pred p] : countp p [] = 0 := rfl

@[simp] theorem countp_cons_of_pos {a : α} (l) (pa : p a) : countp p (a::l) = countp p l + 1 :=
if_pos pa

@[simp] theorem countp_cons_of_neg {a : α} (l) (pa : ¬ p a) : countp p (a::l) = countp p l :=
if_neg pa

theorem countp_eq_length_filter (l) : countp p l = length (filter p l) :=
by induction l with x l; [refl, by_cases (p x)]; simp [*, -add_comm]
local attribute [simp] countp_eq_length_filter

@[simp] theorem countp_append (l₁ l₂) : countp p (l₁ ++ l₂) = countp p l₁ + countp p l₂ :=
by simp

theorem countp_pos {l} : 0 < countp p l ↔ ∃ a ∈ l, p a :=
by simp [countp_eq_length_filter, length_pos_iff_exists_mem]

theorem countp_le_of_sublist {l₁ l₂} (s : l₁ <+ l₂) : countp p l₁ ≤ countp p l₂ :=
by simpa using length_le_of_sublist (filter_sublist_filter s)

end filter

/- count -/

section count
variable [decidable_eq α]

/-- `count a l` is the number of occurrences of `a` in `l`. -/
def count (a : α) : list α → nat := countp (eq a)

@[simp] theorem count_nil (a : α) : count a [] = 0 := rfl

theorem count_cons (a b : α) (l : list α) :
  count a (b :: l) = if a = b then succ (count a l) else count a l := rfl

theorem count_cons' (a b : α) (l : list α) :
  count a (b :: l) = count a l + (if a = b then 1 else 0) :=
decidable.by_cases
  (assume : a = b, begin rw [count_cons, if_pos this, if_pos this] end)
  (assume : a ≠ b, begin rw [count_cons, if_neg this, if_neg this], reflexivity end)


@[simp] theorem count_cons_self (a : α) (l : list α) : count a (a::l) = succ (count a l) :=
if_pos rfl

@[simp] theorem count_cons_of_ne {a b : α} (h : a ≠ b) (l : list α) : count a (b::l) = count a l :=
if_neg h

theorem count_le_of_sublist (a : α) {l₁ l₂} : l₁ <+ l₂ → count a l₁ ≤ count a l₂ :=
countp_le_of_sublist

theorem count_le_count_cons (a b : α) (l : list α) : count a l ≤ count a (b :: l) :=
count_le_of_sublist _ (sublist_cons _ _)

theorem count_singleton (a : α) : count a [a] = 1 :=
by simp

@[simp] theorem count_append (a : α) : ∀ l₁ l₂, count a (l₁ ++ l₂) = count a l₁ + count a l₂ :=
countp_append

@[simp] theorem count_concat (a : α) (l : list α) : count a (concat l a) = succ (count a l) :=
by rw [concat_eq_append, count_append, count_singleton]

theorem count_pos {a : α} {l : list α} : 0 < count a l ↔ a ∈ l :=
by simp [count, countp_pos]

@[simp] theorem count_eq_zero_of_not_mem {a : α} {l : list α} (h : a ∉ l) : count a l = 0 :=
by_contradiction $ λ h', h $ count_pos.1 (nat.pos_of_ne_zero h')

theorem not_mem_of_count_eq_zero {a : α} {l : list α} (h : count a l = 0) : a ∉ l :=
λ h', ne_of_gt (count_pos.2 h') h

@[simp] theorem count_repeat (a : α) (n : ℕ) : count a (repeat a n) = n :=
by rw [count, countp_eq_length_filter, filter_eq_self.2, length_repeat];
   exact λ b m, (eq_of_mem_repeat m).symm

theorem le_count_iff_repeat_sublist {a : α} {l : list α} {n : ℕ} : n ≤ count a l ↔ repeat a n <+ l :=
⟨λ h, ((repeat_sublist_repeat a).2 h).trans $
  have filter (eq a) l = repeat a (count a l), from eq_repeat.2
    ⟨by simp [count, countp_eq_length_filter], λ b m, (of_mem_filter m).symm⟩,
  by rw ← this; apply filter_sublist,
 λ h, by simpa using count_le_of_sublist a h⟩

end count

/- prefix, suffix, infix -/

/-- `is_prefix l₁ l₂`, or `l₁ <+: l₂`, means that `l₁` is a prefix of `l₂`,
  that is, `l₂` has the form `l₁ ++ t` for some `t`. -/
def is_prefix (l₁ : list α) (l₂ : list α) : Prop := ∃ t, l₁ ++ t = l₂

/-- `is_suffix l₁ l₂`, or `l₁ <:+ l₂`, means that `l₁` is a suffix of `l₂`,
  that is, `l₂` has the form `t ++ l₁` for some `t`. -/
def is_suffix (l₁ : list α) (l₂ : list α) : Prop := ∃ t, t ++ l₁ = l₂

/-- `is_infix l₁ l₂`, or `l₁ <:+: l₂`, means that `l₁` is a contiguous
  substring of `l₂`, that is, `l₂` has the form `s ++ l₁ ++ t` for some `s, t`. -/
def is_infix (l₁ : list α) (l₂ : list α) : Prop := ∃ s t, s ++ l₁ ++ t = l₂

infix ` <+: `:50 := is_prefix
infix ` <:+ `:50 := is_suffix
infix ` <:+: `:50 := is_infix

@[simp] theorem prefix_append (l₁ l₂ : list α) : l₁ <+: l₁ ++ l₂ := ⟨l₂, rfl⟩

@[simp] theorem suffix_append (l₁ l₂ : list α) : l₂ <:+ l₁ ++ l₂ := ⟨l₁, rfl⟩

@[simp] theorem infix_append (l₁ l₂ l₃ : list α) : l₂ <:+: l₁ ++ l₂ ++ l₃ := ⟨l₁, l₃, rfl⟩

@[refl] theorem prefix_refl (l : list α) : l <+: l := ⟨[], append_nil _⟩

@[refl] theorem suffix_refl (l : list α) : l <:+ l := ⟨[], rfl⟩

@[simp] theorem suffix_cons (a : α) : ∀ l, l <:+ a :: l := suffix_append [a]

@[simp] theorem prefix_concat (a : α) (l) : l <+: concat l a := by simp

theorem infix_of_prefix {l₁ l₂ : list α} : l₁ <+: l₂ → l₁ <:+: l₂ :=
λ⟨t, h⟩, ⟨[], t, h⟩

theorem infix_of_suffix {l₁ l₂ : list α} : l₁ <:+ l₂ → l₁ <:+: l₂ :=
λ⟨t, h⟩, ⟨t, [], by simp [h]⟩

@[refl] theorem infix_refl (l : list α) : l <:+: l := infix_of_prefix $ prefix_refl l

@[trans] theorem is_prefix.trans : ∀ {l₁ l₂ l₃ : list α}, l₁ <+: l₂ → l₂ <+: l₃ → l₁ <+: l₃
| l ._ ._ ⟨r₁, rfl⟩ ⟨r₂, rfl⟩ := ⟨r₁ ++ r₂, by simp⟩

@[trans] theorem is_suffix.trans : ∀ {l₁ l₂ l₃ : list α}, l₁ <:+ l₂ → l₂ <:+ l₃ → l₁ <:+ l₃
| l ._ ._ ⟨l₁, rfl⟩ ⟨l₂, rfl⟩ := ⟨l₂ ++ l₁, by simp⟩

@[trans] theorem is_infix.trans : ∀ {l₁ l₂ l₃ : list α}, l₁ <:+: l₂ → l₂ <:+: l₃ → l₁ <:+: l₃
| l ._ ._ ⟨l₁, r₁, rfl⟩ ⟨l₂, r₂, rfl⟩ := ⟨l₂ ++ l₁, r₁ ++ r₂, by simp⟩

theorem sublist_of_infix {l₁ l₂ : list α} : l₁ <:+: l₂ → l₁ <+ l₂ :=
λ⟨s, t, h⟩, by rw [← h]; exact (sublist_append_right _ _).trans (sublist_append_left _ _)

theorem sublist_of_prefix {l₁ l₂ : list α} : l₁ <+: l₂ → l₁ <+ l₂ :=
sublist_of_infix ∘ infix_of_prefix

theorem sublist_of_suffix {l₁ l₂ : list α} : l₁ <:+ l₂ → l₁ <+ l₂ :=
sublist_of_infix ∘ infix_of_suffix

theorem length_le_of_infix {l₁ l₂ : list α} (s : l₁ <:+: l₂) : length l₁ ≤ length l₂ :=
length_le_of_sublist $ sublist_of_infix s

theorem eq_nil_of_infix_nil {l : list α} (s : l <:+: []) : l = [] :=
eq_nil_of_sublist_nil $ sublist_of_infix s

theorem eq_nil_of_prefix_nil {l : list α} (s : l <+: []) : l = [] :=
eq_nil_of_infix_nil $ infix_of_prefix s

theorem eq_nil_of_suffix_nil {l : list α} (s : l <:+ []) : l = [] :=
eq_nil_of_infix_nil $ infix_of_suffix s

theorem infix_iff_prefix_suffix (l₁ l₂ : list α) : l₁ <:+: l₂ ↔ ∃ t, l₁ <+: t ∧ t <:+ l₂ :=
⟨λ⟨s, t, e⟩, ⟨l₁ ++ t, ⟨_, rfl⟩, by rw [← e, append_assoc]; exact ⟨_, rfl⟩⟩,
λ⟨._, ⟨t, rfl⟩, ⟨s, e⟩⟩, ⟨s, t, by rw append_assoc; exact e⟩⟩

theorem eq_of_infix_of_length_eq {l₁ l₂ : list α} (s : l₁ <:+: l₂) : length l₁ = length l₂ → l₁ = l₂ :=
eq_of_sublist_of_length_eq $ sublist_of_infix s

theorem eq_of_prefix_of_length_eq {l₁ l₂ : list α} (s : l₁ <+: l₂) : length l₁ = length l₂ → l₁ = l₂ :=
eq_of_sublist_of_length_eq $ sublist_of_prefix s

theorem eq_of_suffix_of_length_eq {l₁ l₂ : list α} (s : l₁ <:+ l₂) : length l₁ = length l₂ → l₁ = l₂ :=
eq_of_sublist_of_length_eq $ sublist_of_suffix s

theorem infix_of_mem_join : ∀ {L : list (list α)} {l}, l ∈ L → l <:+: join L
| (_  :: L) l (or.inl rfl) := infix_append [] _ _
| (l' :: L) l (or.inr h)   :=
  is_infix.trans (infix_of_mem_join h) $ infix_of_suffix $ suffix_append _ _

/-- `inits l` is the list of initial segments of `l`.
  `inits [1, 2, 3] = [[], [1], [1, 2], [1, 2, 3]]` -/
@[simp] def inits : list α → list (list α)
| []     := [[]]
| (a::l) := [] :: map (λt, a::t) (inits l)

@[simp] theorem mem_inits : ∀ (s t : list α), s ∈ inits t ↔ s <+: t
| s []     := suffices s = nil ↔ s <+: nil, by simpa,
  ⟨λh, h.symm ▸ prefix_refl [], eq_nil_of_prefix_nil⟩
| s (a::t) :=
  suffices (s = nil ∨ ∃ l ∈ inits t, a :: l = s) ↔ s <+: a :: t, by simpa,
  ⟨λo, match s, o with
  | ._, or.inl rfl := ⟨_, rfl⟩
  | s, or.inr ⟨r, hr, hs⟩ := let ⟨s, ht⟩ := (mem_inits _ _).1 hr in
    by rw [← hs, ← ht]; exact ⟨s, rfl⟩
  end, λmi, match s, mi with
  | [], ⟨._, rfl⟩ := or.inl rfl
  | (b::s), ⟨r, hr⟩ := list.no_confusion hr $ λba (st : s++r = t), or.inr $
    by rw ba; exact ⟨_, (mem_inits _ _).2 ⟨_, st⟩, rfl⟩
  end⟩

/-- `tails l` is the list of terminal segments of `l`.
  `tails [1, 2, 3] = [[1, 2, 3], [2, 3], [3], []]` -/
@[simp] def tails : list α → list (list α)
| []     := [[]]
| (a::l) := (a::l) :: tails l

@[simp] theorem mem_tails : ∀ (s t : list α), s ∈ tails t ↔ s <:+ t
| s []     := by simp; exact ⟨λh, by rw h; exact suffix_refl [], eq_nil_of_suffix_nil⟩
| s (a::t) := by simp [mem_tails s t]; exact show s = a :: t ∨ s <:+ t ↔ s <:+ a :: t, from
  ⟨λo, match s, t, o with
  | ._, t, or.inl rfl := suffix_refl _
  | s, ._, or.inr ⟨l, rfl⟩ := ⟨a::l, rfl⟩
  end, λe, match s, t, e with
  | ._, t, ⟨[], rfl⟩ := or.inl rfl
  | s, t, ⟨b::l, he⟩ := list.no_confusion he (λab lt, or.inr ⟨l, lt⟩)
  end⟩

/- sublists -/

def sublists'_aux : list α → (list α → list β) → list (list β) → list (list β)
| []     f r := f [] :: r
| (a::l) f r := sublists'_aux l f (sublists'_aux l (f ∘ cons a) r)

/-- `sublists' l` is the list of all (non-contiguous) sublists of `l`.
  It differs from `sublists` only in the order of appearance of the sublists;
  `sublists'` uses the first element of the list as the MSB,
  `sublists` uses the first element of the list as the LSB.
  `sublists' [1, 2, 3] = [[], [3], [2], [2, 3], [1], [1, 3], [1, 2], [1, 2, 3]]` -/
def sublists' (l : list α) : list (list α) :=
sublists'_aux l id []

@[simp] theorem sublists'_nil : sublists' (@nil α) = [[]] := rfl

@[simp] theorem sublists'_singleton (a : α) : sublists' [a] = [[], [a]] := rfl

theorem map_sublists'_aux (g : list β → list γ) (l : list α) (f r) :
  map g (sublists'_aux l f r) = sublists'_aux l (g ∘ f) (map g r) :=
by induction l generalizing f r; simp! *

theorem sublists'_aux_append (r' : list (list β)) (l : list α) (f r) :
  sublists'_aux l f (r ++ r') = sublists'_aux l f r ++ r' :=
by induction l generalizing f r; simp! *

theorem sublists'_aux_eq_sublists' (l f r) :
  @sublists'_aux α β l f r = map f (sublists' l) ++ r :=
by rw [sublists', map_sublists'_aux, ← sublists'_aux_append]; refl

@[simp] theorem sublists'_cons (a : α) (l : list α) :
  sublists' (a :: l) = sublists' l ++ map (cons a) (sublists' l) :=
by rw [sublists', sublists'_aux]; simp [sublists'_aux_eq_sublists']

@[simp] theorem mem_sublists' {s t : list α} : s ∈ sublists' t ↔ s <+ t :=
begin
  induction t with a t IH generalizing s; simp,
  { exact ⟨λ h, by rw h, eq_nil_of_sublist_nil⟩ },
  split; intro h, rcases h with h | ⟨s, h, rfl⟩,
  { exact sublist_cons_of_sublist _ (IH.1 h) },
  { exact cons_sublist_cons _ (IH.1 h) },
  { cases h with _ _ _ h s _ _ h,
    { exact or.inl (IH.2 h) },
    { exact or.inr ⟨s, IH.2 h, rfl⟩ } }
end

@[simp] theorem length_sublists' : ∀ l : list α, length (sublists' l) = 2 ^ length l
| []     := rfl
| (a::l) := by simp [-add_comm, *]; rw [← two_mul, mul_comm]; refl

def sublists_aux : list α → (list α → list β → list β) → list β
| []     f := []
| (a::l) f := f [a] (sublists_aux l (λys r, f ys (f (a :: ys) r)))

/-- `sublists l` is the list of all (non-contiguous) sublists of `l`.
  `sublists [1, 2, 3] = [[], [1], [2], [1, 2], [3], [1, 3], [2, 3], [1, 2, 3]]` -/
def sublists (l : list α) : list (list α) :=
[] :: sublists_aux l cons

@[simp] theorem sublists_nil : sublists (@nil α) = [[]] := rfl

@[simp] theorem sublists_singleton (a : α) : sublists [a] = [[], [a]] := rfl

def sublists_aux₁ : list α → (list α → list β) → list β
| []     f := []
| (a::l) f := f [a] ++ sublists_aux₁ l (λys, f ys ++ f (a :: ys))

theorem sublists_aux₁_eq_sublists_aux : ∀ l (f : list α → list β),
  sublists_aux₁ l f = sublists_aux l (λ ys r, f ys ++ r)
| []     f := rfl
| (a::l) f := by rw [sublists_aux₁, sublists_aux]; simp *

theorem sublists_aux_cons_eq_sublists_aux₁ (l : list α) :
  sublists_aux l cons = sublists_aux₁ l (λ x, [x]) :=
by rw [sublists_aux₁_eq_sublists_aux]; refl

theorem sublists_aux_eq_foldr.aux {a : α} {l : list α}
  (IH₁ : ∀ (f : list α → list β → list β), sublists_aux l f = foldr f [] (sublists_aux l cons))
  (IH₂ : ∀ (f : list α → list (list α) → list (list α)),
      sublists_aux l f = foldr f [] (sublists_aux l cons))
  (f : list α → list β → list β) : sublists_aux (a::l) f = foldr f [] (sublists_aux (a::l) cons) :=
begin
  simp [sublists_aux], rw [IH₂, IH₁], congr_n 1,
  induction sublists_aux l cons with _ _ ih; simp *
end

theorem sublists_aux_eq_foldr (l : list α) : ∀ (f : list α → list β → list β),
  sublists_aux l f = foldr f [] (sublists_aux l cons) :=
suffices _ ∧ ∀ f : list α → list (list α) → list (list α),
    sublists_aux l f = foldr f [] (sublists_aux l cons),
  from this.1,
begin
  induction l with a l IH, {split; intro; refl},
  exact ⟨sublists_aux_eq_foldr.aux IH.1 IH.2,
         sublists_aux_eq_foldr.aux IH.2 IH.2⟩
end

theorem sublists_aux_cons_cons (l : list α) (a : α) :
  sublists_aux (a::l) cons = [a] :: foldr (λys r, ys :: (a :: ys) :: r) [] (sublists_aux l cons) :=
by rw [← sublists_aux_eq_foldr]; refl

theorem sublists_aux₁_append : ∀ (l₁ l₂ : list α) (f : list α → list β),
  sublists_aux₁ (l₁ ++ l₂) f = sublists_aux₁ l₁ f ++
    sublists_aux₁ l₂ (λ x, f x ++ sublists_aux₁ l₁ (f ∘ (++ x)))
| []      l₂ f := by simp [sublists_aux₁]
| (a::l₁) l₂ f := by simp [sublists_aux₁];
  rw [sublists_aux₁_append]; simp

theorem sublists_aux₁_concat (l : list α) (a : α) (f : list α → list β) :
  sublists_aux₁ (l ++ [a]) f = sublists_aux₁ l f ++
    f [a] ++ sublists_aux₁ l (λ x, f (x ++ [a])) :=
by simp [sublists_aux₁_append, sublists_aux₁]

theorem sublists_aux₁_bind : ∀ (l : list α)
  (f : list α → list β) (g : β → list γ),
  (sublists_aux₁ l f).bind g = sublists_aux₁ l (λ x, (f x).bind g)
| []     f g := by simp [sublists_aux₁]
| (a::l) f g := by simp [sublists_aux₁];
  rw [sublists_aux₁_bind]; simp

theorem sublists_aux_cons_append (l₁ l₂ : list α) :
  sublists_aux (l₁ ++ l₂) cons = sublists_aux l₁ cons ++
    (do x ← sublists_aux l₂ cons, (++ x) <$> sublists l₁) :=
begin
  simp [sublists, sublists_aux_cons_eq_sublists_aux₁],
  rw [sublists_aux₁_append, sublists_aux₁_bind],
  congr, funext x, simp,
  rw [← bind_ret_eq_map, sublists_aux₁_bind], simp [list.ret]
end

theorem sublists_append (l₁ l₂ : list α) :
  sublists (l₁ ++ l₂) = (do x ← sublists l₂, (++ x) <$> sublists l₁) :=
by simp [sublists_aux_cons_append, sublists, map_id']

@[simp] theorem sublists_concat (l : list α) (a : α) :
  sublists (l ++ [a]) = sublists l ++ map (λ x, x ++ [a]) (sublists l) :=
by simp [sublists_append];
   rw [sublists, sublists_aux_cons_eq_sublists_aux₁];
   simp [map_id', sublists_aux₁]

theorem sublists_reverse (l : list α) : sublists (reverse l) = map reverse (sublists' l) :=
by induction l; simp [(∘), *]

theorem sublists_eq_sublists' (l : list α) : sublists l = map reverse (sublists' (reverse l)) :=
by rw [← sublists_reverse, reverse_reverse]

theorem sublists'_reverse (l : list α) : sublists' (reverse l) = map reverse (sublists l) :=
by simp [sublists_eq_sublists', map_id']

theorem sublists'_eq_sublists (l : list α) : sublists' l = map reverse (sublists (reverse l)) :=
by rw [← sublists'_reverse, reverse_reverse]

theorem sublists_aux_ne_nil : ∀ (l : list α), [] ∉ sublists_aux l cons
| [] := id
| (a::l) := begin
  rw [sublists_aux_cons_cons],
  refine not_mem_cons_of_ne_of_not_mem (cons_ne_nil _ _).symm _,
  have := sublists_aux_ne_nil l, revert this,
  induction sublists_aux l cons; intro; simp [not_or_distrib],
  exact ⟨ne_of_not_mem_cons this, ih (not_mem_of_not_mem_cons this)⟩
end

@[simp] theorem mem_sublists {s t : list α} : s ∈ sublists t ↔ s <+ t :=
by rw [← reverse_sublist_iff, ← mem_sublists',
       sublists'_reverse, mem_map_of_inj reverse_injective]

@[simp] theorem length_sublists (l : list α) : length (sublists l) = 2 ^ length l :=
by simp [sublists_eq_sublists', length_sublists']

theorem map_ret_sublist_sublists (l : list α) : map list.ret l <+ sublists l :=
reverse_rec_on l (nil_sublist _) $
λ l a IH, by simp; exact
((append_sublist_append_left _).2
  (singleton_sublist.2 $ mem_map.2 ⟨[], by simp [list.ret]⟩)).trans
((append_sublist_append_right _).2 IH)

instance decidable_prefix [decidable_eq α] : ∀ (l₁ l₂ : list α), decidable (l₁ <+: l₂)
| []      l₂ := is_true ⟨l₂, rfl⟩
| (a::l₁) [] := is_false $ λ⟨t, te⟩, list.no_confusion te
| (a::l₁) (b::l₂) :=
  if h : a = b then
    decidable_of_decidable_of_iff (decidable_prefix l₁ l₂) $ by rw [← h]; exact
      ⟨λ⟨t, te⟩, ⟨t, by rw [← te]; refl⟩,
       λ⟨t, te⟩, list.no_confusion te (λ_ te, ⟨t, te⟩)⟩
  else
    is_false $ λ⟨t, te⟩, list.no_confusion te $ λh', absurd h' h

-- Alternatively, use mem_tails
instance decidable_suffix [decidable_eq α] : ∀ (l₁ l₂ : list α), decidable (l₁ <:+ l₂)
| []      l₂ := is_true ⟨l₂, append_nil _⟩
| (a::l₁) [] := is_false $ λ⟨t, te⟩, absurd te $
                append_ne_nil_of_ne_nil_right _ _ $ λh, list.no_confusion h
| l₁      l₂ := let len1 := length l₁, len2 := length l₂ in
  if hl : len1 ≤ len2 then
    if he : drop (len2 - len1) l₂ = l₁ then is_true $
      ⟨take (len2 - len1) l₂, by rw [← he, take_append_drop]⟩
    else is_false $
      suffices length l₁ ≤ length l₂ → l₁ <:+ l₂ → drop (length l₂ - length l₁) l₂ = l₁,
        from λsuf, he (this hl suf),
      λ hl ⟨t, te⟩, append_inj_right'
        ((take_append_drop (length l₂ - length l₁) l₂).trans te.symm)
        (by simp; exact nat.sub_sub_self hl)
  else is_false $ λ⟨t, te⟩, hl $
    show length l₁ ≤ length l₂, by rw [← te, length_append]; apply nat.le_add_left

instance decidable_infix [decidable_eq α] : ∀ (l₁ l₂ : list α), decidable (l₁ <:+: l₂)
| []      l₂ := is_true ⟨[], l₂, rfl⟩
| (a::l₁) [] := is_false $ λ⟨s, t, te⟩, absurd te $ append_ne_nil_of_ne_nil_left _ _ $
                append_ne_nil_of_ne_nil_right _ _ $ λh, list.no_confusion h
| l₁      l₂ := decidable_of_decidable_of_iff (list.decidable_bex (λt, l₁ <+: t) (tails l₂)) $
  by refine (exists_congr (λt, _)).trans (infix_iff_prefix_suffix _ _).symm;
     exact ⟨λ⟨h1, h2⟩, ⟨h2, (mem_tails _ _).1 h1⟩, λ⟨h2, h1⟩, ⟨(mem_tails _ _).2 h1, h2⟩⟩

/- transpose -/

def transpose_aux : list α → list (list α) → list (list α)
| []     ls      := ls
| (a::i) []      := [a] :: transpose_aux i []
| (a::i) (l::ls) := (a::l) :: transpose_aux i ls

/-- transpose of a list of lists, treated as a matrix.
  `transpose [[1, 2], [3, 4], [5, 6]] = [[1, 3, 5], [2, 4, 6]]` -/
def transpose : list (list α) → list (list α)
| []      := []
| (l::ls) := transpose_aux l (transpose ls)

/- permutations -/

section permutations

def permutations_aux2 (t : α) (ts : list α) (r : list β) : list α → (list α → β) → list α × list β
| []      f := (ts, r)
| (y::ys) f := let (us, zs) := permutations_aux2 ys (λx : list α, f (y::x)) in
               (y :: us, f (t :: y :: us) :: zs)

private def meas : (Σ'_:list α, list α) → ℕ × ℕ | ⟨l, i⟩ := (length l + length i, length l)

local infix ` ≺ `:50 := inv_image (prod.lex (<) (<)) meas

@[elab_as_eliminator] def permutations_aux.rec {C : list α → list α → Sort v}
  (H0 : ∀ is, C [] is)
  (H1 : ∀ t ts is, C ts (t::is) → C is [] → C (t::ts) is) : ∀ l₁ l₂, C l₁ l₂
| []      is := H0 is
| (t::ts) is :=
  have h1 : ⟨ts, t :: is⟩ ≺ ⟨t :: ts, is⟩, from
    show prod.lex _ _ (succ (length ts + length is), length ts) (succ (length ts) + length is, length (t :: ts)),
    by rw nat.succ_add; exact prod.lex.right _ _ (lt_succ_self _),
  have h2 : ⟨is, []⟩ ≺ ⟨t :: ts, is⟩, from prod.lex.left _ _ _ (lt_add_of_pos_left _ (succ_pos _)),
  H1 t ts is (permutations_aux.rec ts (t::is)) (permutations_aux.rec is [])
using_well_founded {
  dec_tac := tactic.assumption,
  rel_tac := λ _ _, `[exact ⟨(≺), @inv_image.wf _ _ _ meas (prod.lex_wf lt_wf lt_wf)⟩] }

def permutations_aux : list α → list α → list (list α) :=
@@permutations_aux.rec (λ _ _, list (list α)) (λ is, [])
  (λ t ts is IH1 IH2, foldr (λy r, (permutations_aux2 t ts r y id).2) IH1 (is :: IH2))

/-- List of all permutations of `l`.

     permutations [1, 2, 3] =
       [[1, 2, 3], [2, 1, 3], [3, 2, 1],
        [2, 3, 1], [3, 1, 2], [1, 3, 2]] -/
def permutations (l : list α) : list (list α) :=
l :: permutations_aux l []

@[simp] theorem permutations_aux_nil (is : list α) : permutations_aux [] is = [] :=
by simp [permutations_aux, permutations_aux.rec]

@[simp] theorem permutations_aux_cons (t : α) (ts is : list α) :
  permutations_aux (t :: ts) is = foldr (λy r, (permutations_aux2 t ts r y id).2)
    (permutations_aux ts (t::is)) (permutations is) :=
by simp [permutations_aux, permutations_aux.rec, permutations]

end permutations

/- insert -/
section insert
variable [decidable_eq α]

@[simp] theorem insert_nil (a : α) : insert a nil = [a] := rfl

theorem insert.def (a : α) (l : list α) : insert a l = if a ∈ l then l else a :: l := rfl

@[simp] theorem insert_of_mem {a : α} {l : list α} (h : a ∈ l) : insert a l = l :=
by simp [insert.def, h]

@[simp] theorem insert_of_not_mem {a : α} {l : list α} (h : a ∉ l) : insert a l = a :: l :=
by simp [insert.def, h]

@[simp] theorem mem_insert_iff {a b : α} {l : list α} : a ∈ insert b l ↔ a = b ∨ a ∈ l :=
begin
  by_cases h' : b ∈ l; simp [h'],
  apply (or_iff_right_of_imp _).symm,
  exact λ e, e.symm ▸ h'
end

@[simp] theorem suffix_insert (a : α) (l : list α) : l <:+ insert a l :=
by by_cases a ∈ l; simp *

@[simp] theorem mem_insert_self (a : α) (l : list α) : a ∈ insert a l :=
mem_insert_iff.2 (or.inl rfl)

@[simp] theorem mem_insert_of_mem {a b : α} {l : list α} (h : a ∈ l) : a ∈ insert b l :=
mem_insert_iff.2 (or.inr h)

theorem eq_or_mem_of_mem_insert {a b : α} {l : list α} (h : a ∈ insert b l) : a = b ∨ a ∈ l :=
mem_insert_iff.1 h

@[simp] theorem length_insert_of_mem {a : α} [decidable_eq α] {l : list α} (h : a ∈ l) :
  length (insert a l) = length l :=
by simp [h]

@[simp] theorem length_insert_of_not_mem {a : α} [decidable_eq α] {l : list α} (h : a ∉ l) :
  length (insert a l) = length l + 1 :=
by simp [h]

end insert

/- erase -/
section erase
variable [decidable_eq α]

@[simp] theorem erase_nil (a : α) : [].erase a = [] := rfl

theorem erase_cons (a b : α) (l : list α) : (b :: l).erase a = if b = a then l else b :: l.erase a := rfl

@[simp] theorem erase_cons_head (a : α) (l : list α) : (a :: l).erase a = l :=
by simp [erase_cons]

@[simp] theorem erase_cons_tail {a b : α} (l : list α) (h : b ≠ a) : (b::l).erase a = b :: l.erase a :=
by simp [erase_cons, h]

@[simp] theorem erase_of_not_mem {a : α} {l : list α} (h : a ∉ l) : l.erase a = l :=
by induction l with _ _ ih; [refl,
  simp [(ne_of_not_mem_cons h).symm, ih (not_mem_of_not_mem_cons h)]]

theorem exists_erase_eq {a : α} {l : list α} (h : a ∈ l) :
  ∃ l₁ l₂, a ∉ l₁ ∧ l = l₁ ++ a :: l₂ ∧ l.erase a = l₁ ++ l₂ :=
by induction l with b l ih; [cases h, {
  simp at h,
  by_cases e : b = a,
  { subst b, exact ⟨[], l, not_mem_nil _, rfl, by simp⟩ },
  { exact let ⟨l₁, l₂, h₁, h₂, h₃⟩ := ih (h.resolve_left (ne.symm e)) in
    ⟨b::l₁, l₂, not_mem_cons_of_ne_of_not_mem (ne.symm e) h₁,
      by rw h₂; refl,
      by simp [e, h₃]⟩ } }]

@[simp] theorem length_erase_of_mem {a : α} {l : list α} (h : a ∈ l) : length (l.erase a) = pred (length l) :=
match l, l.erase a, exists_erase_eq h with
| ._, ._, ⟨l₁, l₂, _, rfl, rfl⟩ := by simp [-add_comm]; refl
end

theorem erase_append_left {a : α} : ∀ {l₁ : list α} (l₂), a ∈ l₁ → (l₁++l₂).erase a = l₁.erase a ++ l₂
| (x::xs) l₂  h := begin
  by_cases h' : x = a; simp [h'],
  rw erase_append_left l₂ (mem_of_ne_of_mem (ne.symm h') h)
end

theorem erase_append_right {a : α} : ∀ {l₁ : list α} (l₂), a ∉ l₁ → (l₁++l₂).erase a = l₁ ++ l₂.erase a
| []      l₂ h := rfl
| (x::xs) l₂ h := by simp [*, (ne_of_not_mem_cons h).symm, (not_mem_of_not_mem_cons h)]

theorem erase_sublist (a : α) (l : list α) : l.erase a <+ l :=
if h : a ∈ l then match l, l.erase a, exists_erase_eq h with
| ._, ._, ⟨l₁, l₂, _, rfl, rfl⟩ := by simp
end else by simp [h]

theorem erase_subset (a : α) (l : list α) : l.erase a ⊆ l :=
subset_of_sublist (erase_sublist a l)

theorem erase_sublist_erase (a : α) : ∀ {l₁ l₂ : list α}, l₁ <+ l₂ → l₁.erase a <+ l₂.erase a
| ._ ._ sublist.slnil             := sublist.slnil
| ._ ._ (sublist.cons  l₁ l₂ b s) := if h : b = a
  then by rw [h, erase_cons_head]; exact (erase_sublist _ _).trans s
  else by rw erase_cons_tail _ h; exact (erase_sublist_erase s).cons _ _ _
| ._ ._ (sublist.cons2 l₁ l₂ b s) := if h : b = a
  then by rw [h, erase_cons_head, erase_cons_head]; exact s
  else by rw [erase_cons_tail _ h, erase_cons_tail _ h]; exact (erase_sublist_erase s).cons2 _ _ _

theorem mem_of_mem_erase {a b : α} {l : list α} : a ∈ l.erase b → a ∈ l :=
@erase_subset _ _ _ _ _

@[simp] theorem mem_erase_of_ne {a b : α} {l : list α} (ab : a ≠ b) : a ∈ l.erase b ↔ a ∈ l :=
⟨mem_of_mem_erase, λ al,
  if h : b ∈ l then match l, l.erase b, exists_erase_eq h, al with
  | ._, ._, ⟨l₁, l₂, _, rfl, rfl⟩, al := by simpa [ab] using al
  end else by simp [h, al]⟩

theorem erase_comm (a b : α) (l : list α) : (l.erase a).erase b = (l.erase b).erase a :=
if ab : a = b then by simp [ab] else
if ha : a ∈ l then
if hb : b ∈ l then match l, l.erase a, exists_erase_eq ha, hb with
| ._, ._, ⟨l₁, l₂, ha', rfl, rfl⟩, hb :=
  if h₁ : b ∈ l₁ then
    by rw [erase_append_left _ h₁, erase_append_left _ h₁,
           erase_append_right _ (mt mem_of_mem_erase ha'), erase_cons_head]
  else
    by rw [erase_append_right _ h₁, erase_append_right _ h₁, erase_append_right _ ha',
           erase_cons_tail _ ab, erase_cons_head]
end
else by simp [hb, mt mem_of_mem_erase hb]
else by simp [ha, mt mem_of_mem_erase ha]

end erase

/- diff -/
section diff
variable [decidable_eq α]

@[simp] theorem diff_nil (l : list α) : l.diff [] = l := rfl

@[simp] theorem diff_cons (l₁ l₂ : list α) (a : α) : l₁.diff (a::l₂) = (l₁.erase a).diff l₂ :=
by by_cases a ∈ l₁; simp [list.diff, h]

theorem diff_eq_foldl : ∀ (l₁ l₂ : list α), l₁.diff l₂ = foldl list.erase l₁ l₂
| l₁ []      := rfl
| l₁ (a::l₂) := (diff_cons l₁ l₂ a).trans (diff_eq_foldl _ _)

@[simp] theorem diff_append (l₁ l₂ l₃ : list α) : l₁.diff (l₂ ++ l₃) = (l₁.diff l₂).diff l₃ :=
by simp [diff_eq_foldl]

end diff

/- zip & unzip -/

@[simp] theorem zip_cons_cons (a : α) (b : β) (l₁ : list α) (l₂ : list β) :
  zip (a :: l₁) (b :: l₂) = (a, b) :: zip l₁ l₂ := rfl

@[simp] theorem zip_nil_left (l : list α) : zip ([] : list β) l = [] := rfl

@[simp] theorem zip_nil_right (l : list α) : zip l ([] : list β) = [] :=
by cases l; refl

@[simp] theorem unzip_nil : unzip (@nil (α × β)) = ([], []) := rfl

@[simp] theorem unzip_cons (a : α) (b : β) (l : list (α × β)) :
   unzip ((a, b) :: l) = (a :: (unzip l).1, b :: (unzip l).2) :=
by rw unzip; cases unzip l; refl

theorem zip_unzip : ∀ (l : list (α × β)), zip (unzip l).1 (unzip l).2 = l
| []            := rfl
| ((a, b) :: l) := by simp [zip_unzip l]

/- enum -/

theorem length_enum_from : ∀ n (l : list α), length (enum_from n l) = length l
| n []     := rfl
| n (a::l) := congr_arg nat.succ (length_enum_from _ _)

theorem length_enum : ∀ (l : list α), length (enum l) = length l := length_enum_from _

@[simp] theorem enum_from_nth : ∀ n (l : list α) m,
  nth (enum_from n l) m = (λ a, (n + m, a)) <$> nth l m
| n []       m     := rfl
| n (a :: l) 0     := rfl
| n (a :: l) (m+1) := (enum_from_nth (n+1) l m).trans $
  by rw [add_right_comm]; refl

@[simp] theorem enum_nth : ∀ (l : list α) n,
  nth (enum l) n = (λ a, (n, a)) <$> nth l n :=
by simp [enum]

@[simp] theorem enum_from_map_snd : ∀ n (l : list α),
  map prod.snd (enum_from n l) = l
| n []       := rfl
| n (a :: l) := congr_arg (cons _) (enum_from_map_snd _ _)

@[simp] theorem enum_map_snd : ∀ (l : list α),
  map prod.snd (enum l) = l := enum_from_map_snd _


/- product -/

/-- `product l₁ l₂` is the list of pairs `(a, b)` where `a ∈ l₁` and `b ∈ l₂`.

     product [1, 2] [5, 6] = [(1, 5), (1, 6), (2, 5), (2, 6)] -/
def product (l₁ : list α) (l₂ : list β) : list (α × β) :=
l₁.bind $ λ a, l₂.map $ prod.mk a

@[simp] theorem nil_product (l : list β) : product (@nil α) l = [] := rfl

@[simp] theorem product_cons (a : α) (l₁ : list α) (l₂ : list β)
        : product (a::l₁) l₂ = map (λ b, (a, b)) l₂ ++ product l₁ l₂ := rfl

@[simp] theorem product_nil : ∀ (l : list α), product l (@nil β) = []
| []     := rfl
| (a::l) := by rw [product_cons, product_nil]; refl

@[simp] theorem mem_product {l₁ : list α} {l₂ : list β} {a : α} {b : β} :
  (a, b) ∈ product l₁ l₂ ↔ a ∈ l₁ ∧ b ∈ l₂ :=
by simp [product, and.left_comm]

theorem length_product (l₁ : list α) (l₂ : list β) :
  length (product l₁ l₂) = length l₁ * length l₂ :=
by induction l₁ with x l₁ IH; simp [*, right_distrib]


/- sigma -/
section
variable {σ : α → Type*}

/-- `sigma l₁ l₂` is the list of dependent pairs `(a, b)` where `a ∈ l₁` and `b ∈ l₂ a`.

     sigma [1, 2] (λ_, [5, 6]) = [(1, 5), (1, 6), (2, 5), (2, 6)] -/
def sigma (l₁ : list α) (l₂ : Π a, list (σ a)) : list (Σ a, σ a) :=
l₁.bind $ λ a, (l₂ a).map $ sigma.mk a

@[simp] theorem nil_sigma (l : Π a, list (σ a)) : (@nil α).sigma l = [] := rfl

@[simp] theorem sigma_cons (a : α) (l₁ : list α) (l₂ : Π a, list (σ a))
        : (a::l₁).sigma l₂ = map (sigma.mk a) (l₂ a) ++ l₁.sigma l₂ := rfl

@[simp] theorem sigma_nil : ∀ (l : list α), l.sigma (λ a, @nil (σ a)) = []
| []     := rfl
| (a::l) := by rw [sigma_cons, sigma_nil]; refl

@[simp] theorem mem_sigma {l₁ : list α} {l₂ : Π a, list (σ a)} {a : α} {b : σ a} :
  sigma.mk a b ∈ l₁.sigma l₂ ↔ a ∈ l₁ ∧ b ∈ l₂ a :=
by simp [sigma, and.left_comm]

theorem length_sigma (l₁ : list α) (l₂ : Π a, list (σ a)) :
  length (sigma l₁ l₂) = (l₁.map (λ a, length (l₂ a))).sum :=
by induction l₁ with x l₁ IH; simp *
end

/- disjoint -/
section disjoint

/-- `disjoint l₁ l₂` means that `l₁` and `l₂` have no elements in common. -/
def disjoint (l₁ l₂ : list α) : Prop := ∀ ⦃a⦄, a ∈ l₁ → a ∈ l₂ → false

theorem disjoint.symm {l₁ l₂ : list α} (d : disjoint l₁ l₂) : disjoint l₂ l₁
| a i₂ i₁ := d i₁ i₂

@[simp] theorem disjoint_comm {l₁ l₂ : list α} : disjoint l₁ l₂ ↔ disjoint l₂ l₁ :=
⟨disjoint.symm, disjoint.symm⟩

theorem disjoint_left {l₁ l₂ : list α} : disjoint l₁ l₂ ↔ ∀ {a}, a ∈ l₁ → a ∉ l₂ := iff.rfl

theorem disjoint_right {l₁ l₂ : list α} : disjoint l₁ l₂ ↔ ∀ {a}, a ∈ l₂ → a ∉ l₁ :=
disjoint_comm

theorem disjoint_iff_ne {l₁ l₂ : list α} : disjoint l₁ l₂ ↔ ∀ a ∈ l₁, ∀ b ∈ l₂, a ≠ b :=
by simp [disjoint_left, imp_not_comm]

theorem disjoint_of_subset_left {l₁ l₂ l : list α} (ss : l₁ ⊆ l) (d : disjoint l l₂) : disjoint l₁ l₂
| x m₁ := d (ss m₁)

theorem disjoint_of_subset_right {l₁ l₂ l : list α} (ss : l₂ ⊆ l) (d : disjoint l₁ l) : disjoint l₁ l₂
| x m m₁ := d m (ss m₁)

theorem disjoint_of_disjoint_cons_left {a : α} {l₁ l₂} : disjoint (a::l₁) l₂ → disjoint l₁ l₂ :=
disjoint_of_subset_left (list.subset_cons _ _)

theorem disjoint_of_disjoint_cons_right {a : α} {l₁ l₂} : disjoint l₁ (a::l₂) → disjoint l₁ l₂ :=
disjoint_of_subset_right (list.subset_cons _ _)

@[simp] theorem disjoint_nil_left (l : list α) : disjoint [] l
| a := (not_mem_nil a).elim

@[simp] theorem singleton_disjoint {l : list α} {a : α} : disjoint [a] l ↔ a ∉ l :=
by simp [disjoint]; refl

@[simp] theorem disjoint_singleton {l : list α} {a : α} : disjoint l [a] ↔ a ∉ l :=
by rw disjoint_comm; simp

@[simp] theorem disjoint_append_left {l₁ l₂ l : list α} :
  disjoint (l₁++l₂) l ↔ disjoint l₁ l ∧ disjoint l₂ l :=
by simp [disjoint, or_imp_distrib, forall_and_distrib]

@[simp] theorem disjoint_append_right {l₁ l₂ l : list α} :
  disjoint l (l₁++l₂) ↔ disjoint l l₁ ∧ disjoint l l₂ :=
disjoint_comm.trans $ by simp [disjoint_append_left]

@[simp] theorem disjoint_cons_left {a : α} {l₁ l₂ : list α} :
  disjoint (a::l₁) l₂ ↔ a ∉ l₂ ∧ disjoint l₁ l₂ :=
(@disjoint_append_left _ [a] l₁ l₂).trans $ by simp

@[simp] theorem disjoint_cons_right {a : α} {l₁ l₂ : list α} :
  disjoint l₁ (a::l₂) ↔ a ∉ l₁ ∧ disjoint l₁ l₂ :=
disjoint_comm.trans $ by simp [disjoint_cons_left]

theorem disjoint_of_disjoint_append_left_left {l₁ l₂ l : list α} (d : disjoint (l₁++l₂) l) : disjoint l₁ l :=
(disjoint_append_left.1 d).1

theorem disjoint_of_disjoint_append_left_right {l₁ l₂ l : list α} (d : disjoint (l₁++l₂) l) : disjoint l₂ l :=
(disjoint_append_left.1 d).2

theorem disjoint_of_disjoint_append_right_left {l₁ l₂ l : list α} (d : disjoint l (l₁++l₂)) : disjoint l l₁ :=
(disjoint_append_right.1 d).1

theorem disjoint_of_disjoint_append_right_right {l₁ l₂ l : list α} (d : disjoint l (l₁++l₂)) : disjoint l l₂ :=
(disjoint_append_right.1 d).2

end disjoint

/- union -/
section union
variable [decidable_eq α]

@[simp] theorem nil_union (l : list α) : [] ∪ l = l := rfl

@[simp] theorem cons_union (l₁ l₂ : list α) (a : α) : a :: l₁ ∪ l₂ = insert a (l₁ ∪ l₂) := rfl

@[simp] theorem mem_union {l₁ l₂ : list α} {a : α} : a ∈ l₁ ∪ l₂ ↔ a ∈ l₁ ∨ a ∈ l₂ :=
by induction l₁; simp [*, or_assoc]

theorem mem_union_left {a : α} {l₁ : list α} (h : a ∈ l₁) (l₂ : list α) : a ∈ l₁ ∪ l₂ :=
mem_union.2 (or.inl h)

theorem mem_union_right {a : α} (l₁ : list α) {l₂ : list α} (h : a ∈ l₂) : a ∈ l₁ ∪ l₂ :=
mem_union.2 (or.inr h)

theorem sublist_suffix_of_union : ∀ l₁ l₂ : list α, ∃ t, t <+ l₁ ∧ t ++ l₂ = l₁ ∪ l₂
| [] l₂ := ⟨[], by refl, rfl⟩
| (a::l₁) l₂ := let ⟨t, s, e⟩ := sublist_suffix_of_union l₁ l₂ in
  by simp [e.symm]; by_cases h : a ∈ t ++ l₂;
     [existsi t, existsi a::t]; simp [h];
     [apply sublist_cons_of_sublist _ s, apply cons_sublist_cons _ s]

theorem suffix_union_right (l₁ l₂ : list α) : l₂ <:+ l₁ ∪ l₂ :=
(sublist_suffix_of_union l₁ l₂).imp (λ a, and.right)

theorem union_sublist_append (l₁ l₂ : list α) : l₁ ∪ l₂ <+ l₁ ++ l₂ :=
let ⟨t, s, e⟩ := sublist_suffix_of_union l₁ l₂ in
e ▸ (append_sublist_append_right _).2 s

theorem forall_mem_union {p : α → Prop} {l₁ l₂ : list α} :
  (∀ x ∈ l₁ ∪ l₂, p x) ↔ (∀ x ∈ l₁, p x) ∧ (∀ x ∈ l₂, p x) :=
by simp [or_imp_distrib, forall_and_distrib]

theorem forall_mem_of_forall_mem_union_left {p : α → Prop} {l₁ l₂ : list α}
   (h : ∀ x ∈ l₁ ∪ l₂, p x) : ∀ x ∈ l₁, p x :=
(forall_mem_union.1 h).1

theorem forall_mem_of_forall_mem_union_right {p : α → Prop} {l₁ l₂ : list α}
   (h : ∀ x ∈ l₁ ∪ l₂, p x) : ∀ x ∈ l₂, p x :=
(forall_mem_union.1 h).2

end union

/- inter -/
section inter
variable [decidable_eq α]

@[simp] theorem inter_nil (l : list α) : [] ∩ l = [] := rfl

@[simp] theorem inter_cons_of_mem {a : α} (l₁ : list α) {l₂ : list α} (h : a ∈ l₂) :
  (a::l₁) ∩ l₂ = a :: (l₁ ∩ l₂) :=
if_pos h

@[simp] theorem inter_cons_of_not_mem {a : α} (l₁ : list α) {l₂ : list α} (h : a ∉ l₂) :
  (a::l₁) ∩ l₂ = l₁ ∩ l₂ :=
if_neg h

theorem mem_of_mem_inter_left {l₁ l₂ : list α} {a : α} : a ∈ l₁ ∩ l₂ → a ∈ l₁ :=
mem_of_mem_filter

theorem mem_of_mem_inter_right {l₁ l₂ : list α} {a : α} : a ∈ l₁ ∩ l₂ → a ∈ l₂ :=
of_mem_filter

theorem mem_inter_of_mem_of_mem {l₁ l₂ : list α} {a : α} : a ∈ l₁ → a ∈ l₂ → a ∈ l₁ ∩ l₂ :=
mem_filter_of_mem

@[simp] theorem mem_inter {a : α} {l₁ l₂ : list α} : a ∈ l₁ ∩ l₂ ↔ a ∈ l₁ ∧ a ∈ l₂ :=
mem_filter

theorem inter_subset_left (l₁ l₂ : list α) : l₁ ∩ l₂ ⊆ l₁ :=
filter_subset _

theorem inter_subset_right (l₁ l₂ : list α) : l₁ ∩ l₂ ⊆ l₂ :=
λ a, mem_of_mem_inter_right

theorem subset_inter {l l₁ l₂ : list α} (h₁ : l ⊆ l₁) (h₂ : l ⊆ l₂) : l ⊆ l₁ ∩ l₂ :=
λ a h, mem_inter.2 ⟨h₁ h, h₂ h⟩

theorem inter_eq_nil_iff_disjoint {l₁ l₂ : list α} : l₁ ∩ l₂ = [] ↔ disjoint l₁ l₂ :=
by simp [eq_nil_iff_forall_not_mem]; refl

theorem forall_mem_inter_of_forall_left {p : α → Prop} {l₁ : list α} (h : ∀ x ∈ l₁, p x)
     (l₂ : list α) :
  ∀ x, x ∈ l₁ ∩ l₂ → p x :=
ball.imp_left (λ x, mem_of_mem_inter_left) h

theorem forall_mem_inter_of_forall_right {p : α → Prop} (l₁ : list α) {l₂ : list α}
    (h : ∀ x ∈ l₂, p x) :
  ∀ x, x ∈ l₁ ∩ l₂ → p x :=
ball.imp_left (λ x, mem_of_mem_inter_right) h

end inter

/- bag_inter -/
section bag_inter
variable [decidable_eq α]

@[simp] theorem nil_bag_inter (l : list α) : [].bag_inter l = [] :=
by cases l; refl

@[simp] theorem bag_inter_nil (l : list α) : l.bag_inter [] = [] :=
by cases l; refl

@[simp] theorem cons_bag_inter_of_pos {a} (l₁ : list α) {l₂} (h : a ∈ l₂) :
  (a :: l₁).bag_inter l₂ = a :: l₁.bag_inter (l₂.erase a) :=
by cases l₂; exact if_pos h

@[simp] theorem cons_bag_inter_of_neg {a} (l₁ : list α) {l₂} (h : a ∉ l₂) :
  (a :: l₁).bag_inter l₂ = l₁.bag_inter l₂ :=
by cases l₂; simp [h, list.bag_inter]

theorem mem_bag_inter {a : α} : ∀ {l₁ l₂ : list α}, a ∈ l₁.bag_inter l₂ ↔ a ∈ l₁ ∧ a ∈ l₂
| []      l₂ := by simp
| (b::l₁) l₂ := by
  by_cases b ∈ l₂; simp [*, and_or_distrib_left];
  by_cases ba : a = b; simp *

theorem bag_inter_sublist_left : ∀ l₁ l₂ : list α, l₁.bag_inter l₂ <+ l₁
| []      l₂ := by simp [nil_sublist]
| (b::l₁) l₂ := begin
  by_cases b ∈ l₂; simp [h],
  { apply cons_sublist_cons, apply bag_inter_sublist_left },
  { apply sublist_cons_of_sublist, apply bag_inter_sublist_left }
end

end bag_inter

/- pairwise relation (generalized no duplicate) -/

section pairwise
variable (R : α → α → Prop)

/-- `pairwise R l` means that all the elements with earlier indexes are
  `R`-related to all the elements with later indexes.

     pairwise R [1, 2, 3] ↔ R 1 2 ∧ R 1 3 ∧ R 2 3

  For example if `R = (≠)` then it asserts `l` has no duplicates,
  and if `R = (<)` then it asserts that `l` is (strictly) sorted. -/
inductive pairwise : list α → Prop
| nil  : pairwise []
| cons : ∀ {a : α} {l : list α}, (∀ a' ∈ l, R a a') → pairwise l → pairwise (a::l)
attribute [simp] pairwise.nil

variable {R}
@[simp] theorem pairwise_cons {a : α} {l : list α} :
  pairwise R (a::l) ↔ (∀ a' ∈ l, R a a') ∧ pairwise R l :=
⟨λ p, by cases p with a l n p; exact ⟨n, p⟩, λ ⟨n, p⟩, p.cons n⟩

theorem rel_of_pairwise_cons {a : α} {l : list α}
  (p : pairwise R (a::l)) : ∀ {a'}, a' ∈ l → R a a' :=
(pairwise_cons.1 p).1

theorem pairwise_of_pairwise_cons {a : α} {l : list α}
  (p : pairwise R (a::l)) : pairwise R l :=
(pairwise_cons.1 p).2

theorem pairwise.imp_of_mem {S : α → α → Prop} {l : list α}
  (H : ∀ {a b}, a ∈ l → b ∈ l → R a b → S a b) (p : pairwise R l) : pairwise S l :=
begin
  induction p with a l r p IH generalizing H; constructor,
  { exact ball.imp_right
      (λ x h, H (mem_cons_self _ _) (mem_cons_of_mem _ h)) r },
  { exact IH (λ a b m m', H
      (mem_cons_of_mem _ m) (mem_cons_of_mem _ m')) }
end

theorem pairwise.imp {S : α → α → Prop}
  (H : ∀ a b, R a b → S a b) {l : list α} : pairwise R l → pairwise S l :=
pairwise.imp_of_mem (λ a b _ _, H a b)

theorem pairwise.iff_of_mem {S : α → α → Prop} {l : list α}
  (H : ∀ {a b}, a ∈ l → b ∈ l → (R a b ↔ S a b)) : pairwise R l ↔ pairwise S l :=
⟨pairwise.imp_of_mem (λ a b m m', (H m m').1),
 pairwise.imp_of_mem (λ a b m m', (H m m').2)⟩

theorem pairwise.iff {S : α → α → Prop}
  (H : ∀ a b, R a b ↔ S a b) {l : list α} : pairwise R l ↔ pairwise S l :=
pairwise.iff_of_mem (λ a b _ _, H a b)

theorem pairwise_of_forall {l : list α} (H : ∀ x y, R x y) : pairwise R l :=
by induction l; simp *

theorem pairwise.and_mem {l : list α} :
  pairwise R l ↔ pairwise (λ x y, x ∈ l ∧ y ∈ l ∧ R x y) l :=
pairwise.iff_of_mem (by simp {contextual := tt})

theorem pairwise.imp_mem {l : list α} :
  pairwise R l ↔ pairwise (λ x y, x ∈ l → y ∈ l → R x y) l :=
pairwise.iff_of_mem (by simp {contextual := tt})

theorem pairwise_of_sublist : Π {l₁ l₂ : list α}, l₁ <+ l₂ → pairwise R l₂ → pairwise R l₁
| ._ ._ sublist.slnil h := h
| ._ ._ (sublist.cons l₁ l₂ a s) (pairwise.cons i n) := pairwise_of_sublist s n
| ._ ._ (sublist.cons2 l₁ l₂ a s) (pairwise.cons i n) :=
  (pairwise_of_sublist s n).cons (ball.imp_left (subset_of_sublist s) i)

theorem pairwise_singleton (R) (a : α) : pairwise R [a] :=
by simp

theorem pairwise_pair {a b : α} : pairwise R [a, b] ↔ R a b :=
by simp

theorem pairwise_append {l₁ l₂ : list α} : pairwise R (l₁++l₂) ↔
  pairwise R l₁ ∧ pairwise R l₂ ∧ ∀ x ∈ l₁, ∀ y ∈ l₂, R x y :=
by induction l₁ with x l₁ IH; simp [*,
     or_imp_distrib, forall_and_distrib, and_assoc, and.left_comm]

theorem pairwise_app_comm (s : symmetric R) {l₁ l₂ : list α} :
  pairwise R (l₁++l₂) ↔ pairwise R (l₂++l₁) :=
have ∀ l₁ l₂ : list α,
  (∀ (x : α), x ∈ l₁ → ∀ (y : α), y ∈ l₂ → R x y) →
  (∀ (x : α), x ∈ l₂ → ∀ (y : α), y ∈ l₁ → R x y),
from λ l₁ l₂ a x xm y ym, s (a y ym x xm),
by simp [pairwise_append, and.left_comm]; rw iff.intro (this l₁ l₂) (this l₂ l₁)

theorem pairwise_middle (s : symmetric R) {a : α} {l₁ l₂ : list α} :
  pairwise R (l₁ ++ a::l₂) ↔ pairwise R (a::(l₁++l₂)) :=
show pairwise R (l₁ ++ ([a] ++ l₂)) ↔ pairwise R ([a] ++ l₁ ++ l₂),
by rw [← append_assoc, pairwise_append, @pairwise_append _ _ ([a] ++ l₁), pairwise_app_comm s];
   simp only [mem_append, or_comm]

theorem pairwise_map (f : β → α) :
  ∀ {l : list β}, pairwise R (map f l) ↔ pairwise (λ a b : β, R (f a) (f b)) l
| []     := by simp
| (b::l) :=
  have (∀ a b', b' ∈ l → f b' = a → R (f b) a) ↔ ∀ (b' : β), b' ∈ l → R (f b) (f b'), from
  forall_swap.trans $ forall_congr $ λ a, forall_swap.trans $ by simp,
  by simp *; rw this

theorem pairwise_of_pairwise_map {S : β → β → Prop} (f : α → β)
  (H : ∀ a b : α, S (f a) (f b) → R a b) {l : list α}
  (p : pairwise S (map f l)) : pairwise R l :=
((pairwise_map f).1 p).imp H

theorem pairwise_map_of_pairwise {S : β → β → Prop} (f : α → β)
  (H : ∀ a b : α, R a b → S (f a) (f b)) {l : list α}
  (p : pairwise R l) : pairwise S (map f l) :=
(pairwise_map f).2 $ p.imp H

theorem pairwise_filter_map (f : β → option α) {l : list β} :
  pairwise R (filter_map f l) ↔ pairwise (λ a a' : β, ∀ (b ∈ f a) (b' ∈ f a'), R b b') l :=
let S (a a' : β) := ∀ (b ∈ f a) (b' ∈ f a'), R b b' in
begin
  simp, induction l with a l IH; simp,
  cases e : f a with b; simp [e, IH],
  rw [filter_map_cons_some _ _ _ e], simp [IH],
  show (∀ (a' : α) (x : β), x ∈ l → f x = some a' → R b a') ∧ pairwise S l ↔
        (∀ (a' : β), a' ∈ l → ∀ (b' : α), f a' = some b' → R b b') ∧ pairwise S l,
  from and_congr ⟨λ h b mb a ma, h a b mb ma, λ h a b mb ma, h b mb a ma⟩ iff.rfl
end

theorem pairwise_filter_map_of_pairwise {S : β → β → Prop} (f : α → option β)
  (H : ∀ (a a' : α), R a a' → ∀ (b ∈ f a) (b' ∈ f a'), S b b') {l : list α}
  (p : pairwise R l) : pairwise S (filter_map f l) :=
(pairwise_filter_map _).2 $ p.imp H

theorem pairwise_filter (p : α → Prop) [decidable_pred p] {l : list α} :
  pairwise R (filter p l) ↔ pairwise (λ x y, p x → p y → R x y) l :=
begin
  rw [← filter_map_eq_filter, pairwise_filter_map],
  apply pairwise.iff, simp
end

theorem pairwise_filter_of_pairwise (p : α → Prop) [decidable_pred p] {l : list α}
  : pairwise R l → pairwise R (filter p l) :=
pairwise_of_sublist (filter_sublist _)

theorem pairwise_join {L : list (list α)} : pairwise R (join L) ↔
  (∀ l ∈ L, pairwise R l) ∧ pairwise (λ l₁ l₂, ∀ (x ∈ l₁) (y ∈ l₂), R x y) L :=
begin
  induction L with l L IH, {simp},
  have : (∀ (x : α), x ∈ l → ∀ (y : α) (x_1 : list α), x_1 ∈ L → y ∈ x_1 → R x y) ↔
          ∀ (a' : list α), a' ∈ L → ∀ (x : α), x ∈ l → ∀ (y : α), y ∈ a' → R x y :=
    ⟨λ h a b c d e, h c d e a b, λ h c d e a b, h a b c d e⟩,
  simp [pairwise_append, IH, this], simp [and_assoc, and_comm, and.left_comm],
end

@[simp] theorem pairwise_reverse : ∀ {R} {l : list α},
  pairwise R (reverse l) ↔ pairwise (λ x y, R y x) l :=
suffices ∀ {R l}, @pairwise α R l → pairwise (λ x y, R y x) (reverse l),
from λ R l, ⟨λ p, reverse_reverse l ▸ this p, this⟩,
λ R l p, by induction p with a l h p IH;
  [simp, simpa [pairwise_append, IH] using h]

theorem pairwise_iff_nth_le {R} : ∀ {l : list α},
  pairwise R l ↔ ∀ i j (h₁ : j < length l) (h₂ : i < j), R (nth_le l i (lt_trans h₂ h₁)) (nth_le l j h₁)
| [] := by simp; exact λ i j h, (not_lt_zero j).elim h
| (a::l) := begin
  rw [pairwise_cons, pairwise_iff_nth_le],
  refine ⟨λ H i j h₁ h₂, _, λ H, ⟨λ a' m, _,
    λ i j h₁ h₂, H _ _ (succ_lt_succ h₁) (succ_lt_succ h₂)⟩⟩,
  { cases j with j, {exact (not_lt_zero _).elim h₂},
    cases i with i,
    { apply H.1, simp [nth_le_mem] },
    { exact H.2 _ _ (lt_of_succ_lt_succ h₁) (lt_of_succ_lt_succ h₂) } },
  { rcases nth_le_of_mem m with ⟨n, h, rfl⟩,
    exact H _ _ (succ_lt_succ h) (succ_pos _) }
end

inductive lex (R : α → α → Prop) : list α → list α → Prop
| nil {} (a l) : lex [] (a::l)
| cons {} (a) {l l'} : lex l l' → lex (a::l) (a::l')
| rel {a a'} (l l') : R a a' → lex (a::l) (a'::l')

theorem lex_append_right (R : α → α → Prop) :
  ∀ {s₁ s₂} t, lex R s₁ s₂ → lex R s₁ (s₂ ++ t)
| _ _ t (lex.nil a l)   := lex.nil _ _
| _ _ t (lex.cons a h)  := lex.cons _ (lex_append_right _ h)
| _ _ t (lex.rel _ _ r) := lex.rel _ _ r

theorem lex_append_left (R : α → α → Prop) {t₁ t₂} (h : lex R t₁ t₂) :
  ∀ s, lex R (s ++ t₁) (s ++ t₂)
| []      := h
| (a::l) := lex.cons _ (lex_append_left l)

theorem lex.imp {R S : α → α → Prop} (H : ∀ a b, R a b → S a b) :
  ∀ l₁ l₂, lex R l₁ l₂ → lex S l₁ l₂
| _ _ (lex.nil a l)   := lex.nil _ _
| _ _ (lex.cons a h)  := lex.cons _ (lex.imp _ _ h)
| _ _ (lex.rel _ _ r) := lex.rel _ _ (H _ _ r)

theorem ne_of_lex_ne : ∀ {l₁ l₂ : list α}, lex (≠) l₁ l₂ → l₁ ≠ l₂
| _ _ (lex.cons a h)  e := ne_of_lex_ne h (list.cons.inj e).2
| _ _ (lex.rel _ _ r) e := r (list.cons.inj e).1

theorem lex_ne_iff {l₁ l₂ : list α} (H : length l₁ ≤ length l₂) :
  lex (≠) l₁ l₂ ↔ l₁ ≠ l₂ :=
⟨ne_of_lex_ne, λ h, begin
  induction l₁ with a l₁ IH generalizing l₂; cases l₂ with b l₂,
  { contradiction },
  { apply lex.nil },
  { exact (not_lt_of_ge H).elim (succ_pos _) },
  { cases classical.em (a = b) with ab ab,
    { subst b, apply lex.cons,
      exact IH (le_of_succ_le_succ H) (mt (congr_arg _) h) },
    { exact lex.rel _ _ ab } }
end⟩

theorem pairwise_sublists' {R} : ∀ {l : list α}, pairwise R l →
  pairwise (lex (swap R)) (sublists' l)
| _ (pairwise.nil _) := pairwise_singleton _ _
| _ (@pairwise.cons _ _ a l H₁ H₂) :=
  begin
    simp [pairwise_append, pairwise_map],
    have IH := pairwise_sublists' H₂,
    refine ⟨IH, IH.imp (λ l₁ l₂, lex.cons _), _⟩,
    intros l₁ sl₁ x l₂ sl₂ e, subst e,
    cases l₁ with b l₁, {constructor},
    exact lex.rel _ _ (H₁ _ $ subset_of_sublist sl₁ $ mem_cons_self _ _)
  end

theorem pairwise_sublists {R} {l : list α} (H : pairwise R l) :
  pairwise (λ l₁ l₂, lex R (reverse l₁) (reverse l₂)) (sublists l) :=
by have := pairwise_sublists' (pairwise_reverse.2 H);
   rwa [sublists'_reverse, pairwise_map] at this

variable [decidable_rel R]
instance decidable_pairwise (l : list α) : decidable (pairwise R l) :=
by induction l; simp; resetI; apply_instance

/- pairwise reduct -/

/-- `pw_filter R l` is a maximal sublist of `l` which is `pairwise R`.
  `pw_filter (≠)` is the erase duplicates function, and `pw_filter (<)` finds
  a maximal increasing subsequence in `l`. For example,

     pw_filter (<) [0, 1, 5, 2, 6, 3, 4] = [0, 1, 5, 6] -/
def pw_filter (R : α → α → Prop) [decidable_rel R] : list α → list α
| []        := []
| (x :: xs) := let IH := pw_filter xs in if ∀ y ∈ IH, R x y then x :: IH else IH

@[simp] theorem pw_filter_nil : pw_filter R [] = [] := rfl

@[simp] theorem pw_filter_cons_of_pos {a : α} {l : list α} (h : ∀ b ∈ pw_filter R l, R a b) :
  pw_filter R (a::l) = a :: pw_filter R l := if_pos h

@[simp] theorem pw_filter_cons_of_neg {a : α} {l : list α} (h : ¬ ∀ b ∈ pw_filter R l, R a b) :
  pw_filter R (a::l) = pw_filter R l := if_neg h

theorem pw_filter_sublist : ∀ (l : list α), pw_filter R l <+ l
| []     := nil_sublist _
| (x::l) := begin
  by_cases (∀ y ∈ pw_filter R l, R x y); dsimp at h,
  { rw [pw_filter_cons_of_pos h],
    exact cons_sublist_cons _ (pw_filter_sublist l) },
  { rw [pw_filter_cons_of_neg h],
    exact sublist_cons_of_sublist _ (pw_filter_sublist l) },
end

theorem pw_filter_subset (l : list α) : pw_filter R l ⊆ l :=
subset_of_sublist (pw_filter_sublist _)

theorem pairwise_pw_filter : ∀ (l : list α), pairwise R (pw_filter R l)
| []     := pairwise.nil _
| (x::l) := begin
  by_cases (∀ y ∈ pw_filter R l, R x y); dsimp at h,
  { rw [pw_filter_cons_of_pos h],
    exact pairwise_cons.2 ⟨h, pairwise_pw_filter l⟩ },
  { rw [pw_filter_cons_of_neg h],
    exact pairwise_pw_filter l },
end

theorem pw_filter_eq_self {l : list α} : pw_filter R l = l ↔ pairwise R l :=
⟨λ e, e ▸ pairwise_pw_filter l, λ p, begin
  induction l with x l IH, {simp},
  cases pairwise_cons.1 p with al p,
  rw [pw_filter_cons_of_pos (ball.imp_left (pw_filter_subset l) al), IH p],
end⟩

theorem forall_mem_pw_filter (neg_trans : ∀ {x y z}, R x z → R x y ∨ R y z)
  (a : α) (l : list α) : (∀ b ∈ pw_filter R l, R a b) ↔ (∀ b ∈ l, R a b) :=
⟨begin
  induction l with x l IH; simp *,
  by_cases (∀ y ∈ pw_filter R l, R x y); dsimp at h,
  { simp [pw_filter_cons_of_pos h],
    exact λ r H, ⟨r, IH H⟩ },
  { rw [pw_filter_cons_of_neg h],
    refine λ H, ⟨_, IH H⟩,
    cases e : find (λ y, ¬ R x y) (pw_filter R l) with k,
    { refine h.elim (ball.imp_right _ (find_eq_none.1 e)),
      exact λ y _, not_not.1 },
    { have := find_some e,
      exact (neg_trans (H k (find_mem e))).resolve_right this } }
end, ball.imp_left (pw_filter_subset l)⟩

end pairwise

/- chain relation (conjunction of R a b ∧ R b c ∧ R c d ...) -/

section chain
variable (R : α → α → Prop)

/-- `chain R a l` means that `R` holds between adjacent elements of `a::l`.
  `chain R a [b, c, d] ↔ R a b ∧ R b c ∧ R c d` -/
inductive chain : α → list α → Prop
| nil  (a : α) : chain a []
| cons : ∀ {a b : α} {l : list α}, R a b → chain b l → chain a (b::l)
attribute [simp] chain.nil

variable {R}
@[simp] theorem chain_cons {a b : α} {l : list α} :
  chain R a (b::l) ↔ R a b ∧ chain R b l :=
⟨λ p, by cases p with _ a b l n p; exact ⟨n, p⟩, λ ⟨n, p⟩, p.cons n⟩

theorem rel_of_chain_cons {a b : α} {l : list α}
  (p : chain R a (b::l)) : R a b :=
(chain_cons.1 p).1

theorem chain_of_chain_cons {a b : α} {l : list α}
  (p : chain R a (b::l)) : chain R b l :=
(chain_cons.1 p).2

theorem chain.imp {S : α → α → Prop}
  (H : ∀ a b, R a b → S a b) {a : α} {l : list α} (p : chain R a l) : chain S a l :=
by induction p with _ a b l r p IH; constructor;
   [exact H _ _ r, exact IH]

theorem chain.iff {S : α → α → Prop}
  (H : ∀ a b, R a b ↔ S a b) {a : α} {l : list α} : chain R a l ↔ chain S a l :=
⟨chain.imp (λ a b, (H a b).1), chain.imp (λ a b, (H a b).2)⟩

theorem chain.iff_mem {S : α → α → Prop} {a : α} {l : list α} :
  chain R a l ↔ chain (λ x y, x ∈ a :: l ∧ y ∈ l ∧ R x y) a l :=
⟨λ p, by induction p with _ a b l r p IH; constructor;
  [exact ⟨mem_cons_self _ _, mem_cons_self _ _, r⟩,
   exact IH.imp (λ a b ⟨am, bm, h⟩,
    ⟨mem_cons_of_mem _ am, mem_cons_of_mem _ bm, h⟩)],
 chain.imp (λ a b h, h.2.2)⟩

theorem chain_singleton {a b : α} : chain R a [b] ↔ R a b :=
by simp

theorem chain_split {a b : α} {l₁ l₂ : list α} : chain R a (l₁++b::l₂) ↔
  chain R a (l₁++[b]) ∧ chain R b l₂ :=
by induction l₁ with x l₁ IH generalizing a; simp [*, and_assoc]

theorem chain_map (f : β → α) {b : β} {l : list β} :
  chain R (f b) (map f l) ↔ chain (λ a b : β, R (f a) (f b)) b l :=
by induction l generalizing b; simp *

theorem chain_of_chain_map {S : β → β → Prop} (f : α → β)
  (H : ∀ a b : α, S (f a) (f b) → R a b) {a : α} {l : list α}
  (p : chain S (f a) (map f l)) : chain R a l :=
((chain_map f).1 p).imp H

theorem chain_map_of_chain {S : β → β → Prop} (f : α → β)
  (H : ∀ a b : α, R a b → S (f a) (f b)) {a : α} {l : list α}
  (p : chain R a l) : chain S (f a) (map f l) :=
(chain_map f).2 $ p.imp H

theorem chain_of_pairwise {a : α} {l : list α} (p : pairwise R (a::l)) : chain R a l :=
begin
  cases pairwise_cons.1 p with r p', clear p,
  induction p' with b l r' p IH generalizing a; simp,
  simp at r, simp [r],
  show chain R b l, from IH r'
end

theorem chain_iff_pairwise (tr : transitive R) {a : α} {l : list α} :
  chain R a l ↔ pairwise R (a::l) :=
⟨λ c, begin
  induction c with b b c l r p IH, {simp},
  apply IH.cons _, simp [r],
  show ∀ x ∈ l, R b x, from λ x m, (tr r (rel_of_pairwise_cons IH m)),
end, chain_of_pairwise⟩

instance decidable_chain [decidable_rel R] (a : α) (l : list α) : decidable (chain R a l) :=
by induction l generalizing a; simp; resetI; apply_instance

end chain

/- no duplicates predicate -/

/-- `nodup l` means that `l` has no duplicates, that is, any element appears at most
  once in the list. It is defined as `pairwise (≠)`. -/
def nodup : list α → Prop := pairwise (≠)

section nodup

@[simp] theorem forall_mem_ne {a : α} {l : list α} : (∀ (a' : α), a' ∈ l → ¬a = a') ↔ a ∉ l :=
⟨λ h m, h _ m rfl, λ h a' m e, h (e.symm ▸ m)⟩

@[simp] theorem nodup_nil : @nodup α [] := pairwise.nil _

@[simp] theorem nodup_cons {a : α} {l : list α} : nodup (a::l) ↔ a ∉ l ∧ nodup l :=
by simp [nodup]

theorem nodup_cons_of_nodup {a : α} {l : list α} (m : a ∉ l) (n : nodup l) : nodup (a::l) :=
nodup_cons.2 ⟨m, n⟩

theorem nodup_singleton (a : α) : nodup [a] :=
nodup_cons_of_nodup (not_mem_nil a) nodup_nil

theorem nodup_of_nodup_cons {a : α} {l : list α} (h : nodup (a::l)) : nodup l :=
(nodup_cons.1 h).2

theorem not_mem_of_nodup_cons {a : α} {l : list α} (h : nodup (a::l)) : a ∉ l :=
(nodup_cons.1 h).1

theorem not_nodup_cons_of_mem {a : α} {l : list α} : a ∈ l → ¬ nodup (a :: l) :=
imp_not_comm.1 not_mem_of_nodup_cons

theorem nodup_of_sublist {l₁ l₂ : list α} : l₁ <+ l₂ → nodup l₂ → nodup l₁ :=
pairwise_of_sublist

theorem not_nodup_pair (a : α) : ¬ nodup [a, a] :=
not_nodup_cons_of_mem $ mem_singleton_self _

theorem nodup_iff_sublist {l : list α} : nodup l ↔ ∀ a, ¬ [a, a] <+ l :=
⟨λ d a h, not_nodup_pair a (nodup_of_sublist h d), begin
  induction l with a l IH; intro h, {simp},
  exact nodup_cons_of_nodup
    (λ al, h a $ cons_sublist_cons _ $ singleton_sublist.2 al)
    (IH $ λ a s, h a $ sublist_cons_of_sublist _ s)
end⟩

theorem nodup_iff_nth_le_inj {l : list α} :
  nodup l ↔ ∀ i j h₁ h₂, nth_le l i h₁ = nth_le l j h₂ → i = j :=
pairwise_iff_nth_le.trans
⟨λ H i j h₁ h₂ h, ((lt_trichotomy _ _)
  .resolve_left (λ h', H _ _ h₂ h' h))
  .resolve_right (λ h', H _ _ h₁ h' h.symm),
 λ H i j h₁ h₂ h, ne_of_lt h₂ (H _ _ _ _ h)⟩

@[simp] theorem nth_le_index_of [decidable_eq α] {l : list α} (H : nodup l) (n h) : index_of (nth_le l n h) l = n :=
nodup_iff_nth_le_inj.1 H _ _ _ h $
index_of_nth_le $ index_of_lt_length.2 $ nth_le_mem _ _ _

theorem nodup_iff_count_le_one [decidable_eq α] {l : list α} : nodup l ↔ ∀ a, count a l ≤ 1 :=
nodup_iff_sublist.trans $ forall_congr $ λ a,
have [a, a] <+ l ↔ 1 < count a l, from (@le_count_iff_repeat_sublist _ _ a l 2).symm,
(not_congr this).trans not_lt

@[simp] theorem count_eq_one_of_mem [decidable_eq α] {a : α} {l : list α}
  (d : nodup l) (h : a ∈ l) : count a l = 1 :=
le_antisymm (nodup_iff_count_le_one.1 d a) (count_pos.2 h)

theorem nodup_of_nodup_append_left {l₁ l₂ : list α} : nodup (l₁++l₂) → nodup l₁ :=
nodup_of_sublist (sublist_append_left l₁ l₂)

theorem nodup_of_nodup_append_right {l₁ l₂ : list α} : nodup (l₁++l₂) → nodup l₂ :=
nodup_of_sublist (sublist_append_right l₁ l₂)

theorem nodup_append {l₁ l₂ : list α} : nodup (l₁++l₂) ↔ nodup l₁ ∧ nodup l₂ ∧ disjoint l₁ l₂ :=
by simp [nodup, pairwise_append, disjoint_iff_ne]

theorem disjoint_of_nodup_append {l₁ l₂ : list α} (d : nodup (l₁++l₂)) : disjoint l₁ l₂ :=
(nodup_append.1 d).2.2

theorem nodup_append_of_nodup {l₁ l₂ : list α} (d₁ : nodup l₁) (d₂ : nodup l₂) (dj : disjoint l₁ l₂) : nodup (l₁++l₂) :=
nodup_append.2 ⟨d₁, d₂, dj⟩

theorem nodup_app_comm {l₁ l₂ : list α} : nodup (l₁++l₂) ↔ nodup (l₂++l₁) :=
by simp [nodup_append, and.left_comm]

theorem nodup_middle {a : α} {l₁ l₂ : list α} : nodup (l₁ ++ a::l₂) ↔ nodup (a::(l₁++l₂)) :=
by simp [nodup_append, not_or_distrib, and.left_comm, and_assoc]

theorem nodup_of_nodup_map (f : α → β) {l : list α} : nodup (map f l) → nodup l :=
pairwise_of_pairwise_map f $ λ a b, mt $ congr_arg f

theorem nodup_map_on {f : α → β} {l : list α} (H : ∀x∈l, ∀y∈l, f x = f y → x = y)
  (d : nodup l) : nodup (map f l) :=
pairwise_map_of_pairwise _ (by exact λ a b ⟨ma, mb, n⟩ e, n (H a ma b mb e)) (pairwise.and_mem.1 d)

theorem nodup_map {f : α → β} {l : list α} (hf : injective f) : nodup l → nodup (map f l) :=
nodup_map_on (assume x _ y _ h, hf h)

theorem nodup_map_iff {f : α → β} {l : list α} (hf : injective f) : nodup (map f l) ↔ nodup l :=
⟨nodup_of_nodup_map _, nodup_map hf⟩

@[simp] theorem nodup_attach {l : list α} : nodup (attach l) ↔ nodup l :=
⟨λ h, attach_map_val l ▸ nodup_map (λ a b, subtype.eq) h,
 λ h, nodup_of_nodup_map subtype.val ((attach_map_val l).symm ▸ h)⟩

theorem nodup_pmap {p : α → Prop} {f : Π a, p a → β} {l : list α} {H}
  (hf : ∀ a ha b hb, f a ha = f b hb → a = b) (h : nodup l) : nodup (pmap f l H) :=
by rw [pmap_eq_map_attach]; exact nodup_map
  (λ ⟨a, ha⟩ ⟨b, hb⟩ h, by congr; exact hf a (H _ ha) b (H _ hb) h)
  (nodup_attach.2 h)

theorem nodup_filter (p : α → Prop) [decidable_pred p] {l} : nodup l → nodup (filter p l) :=
pairwise_filter_of_pairwise p

@[simp] theorem nodup_reverse {l : list α} : nodup (reverse l) ↔ nodup l :=
pairwise_reverse.trans $ by simp [nodup, eq_comm]

instance nodup_decidable [decidable_eq α] : ∀ l : list α, decidable (nodup l) :=
list.decidable_pairwise

theorem nodup_erase_eq_filter [decidable_eq α] (a : α) {l} (d : nodup l) : l.erase a = filter (≠ a) l :=
begin
  induction d with b l m d IH; simp [list.erase, list.filter],
  by_cases b = a; simp *, subst b,
  show l = filter (λ a', ¬ a' = a) l, rw filter_eq_self.2,
  simpa only [eq_comm] using m
end

theorem nodup_erase_of_nodup [decidable_eq α] (a : α) {l} : nodup l → nodup (l.erase a) :=
nodup_of_sublist (erase_sublist _ _)

theorem mem_erase_iff_of_nodup [decidable_eq α] {a b : α} {l} (d : nodup l) :
  a ∈ l.erase b ↔ a ≠ b ∧ a ∈ l :=
by rw nodup_erase_eq_filter b d; simp [and_comm]

theorem mem_erase_of_nodup [decidable_eq α] {a : α} {l} (h : nodup l) : a ∉ l.erase a :=
by rw mem_erase_iff_of_nodup h; simp

theorem nodup_join {L : list (list α)} : nodup (join L) ↔ (∀ l ∈ L, nodup l) ∧ pairwise disjoint L :=
by simp [nodup, pairwise_join, disjoint_left.symm]

theorem nodup_bind {l₁ : list α} {f : α → list β} : nodup (l₁.bind f) ↔
  (∀ x ∈ l₁, nodup (f x)) ∧ pairwise (λ (a b : α), disjoint (f a) (f b)) l₁ :=
by simp [list.bind, nodup_join, pairwise_map, and_comm, and.left_comm];
   rw [show (∀ (l : list β) (x : α), f x = l → x ∈ l₁ → nodup l) ↔
            (∀ (x : α), x ∈ l₁ → nodup (f x)),
       from forall_swap.trans $ forall_congr $ λ_, by simp]

theorem nodup_product {l₁ : list α} {l₂ : list β} (d₁ : nodup l₁) (d₂ : nodup l₂) :
  nodup (product l₁ l₂) :=
 nodup_bind.2
  ⟨λ a ma, nodup_map (injective_of_left_inverse (λ b, (rfl : (a,b).2 = b))) d₂,
  d₁.imp (λ a₁ a₂ n x,
    suffices ∀ (b₁ : β), b₁ ∈ l₂ → (a₁, b₁) = x → ∀ (b₂ : β), b₂ ∈ l₂ → (a₂, b₂) ≠ x, by simpa,
    λ b₁ mb₁ e b₂ mb₂ e', by subst e'; injection e; contradiction)⟩

theorem nodup_sigma {σ : α → Type*} {l₁ : list α} {l₂ : Π a, list (σ a)}
  (d₁ : nodup l₁) (d₂ : ∀ a, nodup (l₂ a)) : nodup (sigma l₁ l₂) :=
 nodup_bind.2
  ⟨λ a ma, nodup_map (λ b b' h, by injection h with _ h; exact eq_of_heq h) (d₂ a),
  d₁.imp (λ a₁ a₂ n x,
    suffices ∀ (b₁ : σ a₁), sigma.mk a₁ b₁ = x → b₁ ∈ l₂ a₁ →
      ∀ (b₂ : σ a₂), sigma.mk a₂ b₂ = x → b₂ ∉ l₂ a₂, by simpa [and_comm],
    λ b₁ e mb₁ b₂ e' mb₂, by subst e'; injection e; contradiction)⟩

theorem nodup_filter_map {f : α → option β} {l : list α}
  (H : ∀ (a a' : α) (b : β), b ∈ f a → b ∈ f a' → a = a') :
  nodup l → nodup (filter_map f l) :=
pairwise_filter_map_of_pairwise f $ λ a a' n b bm b' bm' e, n $ H a a' b' (e ▸ bm) bm'

theorem nodup_concat {a : α} {l : list α} (h : a ∉ l) (h' : nodup l) : nodup (concat l a) :=
by simp; exact nodup_append_of_nodup h' (nodup_singleton _) (disjoint_singleton.2 h)

theorem nodup_insert [decidable_eq α] {a : α} {l : list α} (h : nodup l) : nodup (insert a l) :=
by by_cases h' : a ∈ l; simp [h', h]; apply nodup_cons h' h

theorem nodup_union [decidable_eq α] (l₁ : list α) {l₂ : list α} (h : nodup l₂) :
  nodup (l₁ ∪ l₂) :=
begin
  induction l₁ with a l₁ ih generalizing l₂,
  { exact h },
  simp,
  apply nodup_insert,
  exact ih h
end

theorem nodup_inter_of_nodup [decidable_eq α] {l₁ : list α} (l₂) : nodup l₁ → nodup (l₁ ∩ l₂) :=
nodup_filter _

@[simp] theorem nodup_sublists {l : list α} : nodup (sublists l) ↔ nodup l :=
⟨λ h, nodup_of_nodup_map _ (nodup_of_sublist (map_ret_sublist_sublists _) h),
 λ h, (pairwise_sublists h).imp (λ _ _ h, mt reverse_inj.2 (ne_of_lex_ne h))⟩

@[simp] theorem nodup_sublists' {l : list α} : nodup (sublists' l) ↔ nodup l :=
by rw [sublists'_eq_sublists, nodup_map_iff reverse_injective,
       nodup_sublists, nodup_reverse]

end nodup

/- erase duplicates function -/

section erase_dup
variable [decidable_eq α]

/-- `erase_dup l` removes duplicates from `l` (taking only the first occurrence).

     erase_dup [1, 2, 2, 0, 1] = [1, 2, 0] -/
def erase_dup : list α → list α := pw_filter (≠)

@[simp] theorem erase_dup_nil : erase_dup [] = ([] : list α) := rfl

theorem erase_dup_cons_of_mem' {a : α} {l : list α} (h : a ∈ erase_dup l) :
  erase_dup (a::l) = erase_dup l :=
pw_filter_cons_of_neg $ by simpa using h

theorem erase_dup_cons_of_not_mem' {a : α} {l : list α} (h : a ∉ erase_dup l) :
  erase_dup (a::l) = a :: erase_dup l :=
pw_filter_cons_of_pos $ by simpa using h

@[simp] theorem mem_erase_dup {a : α} {l : list α} : a ∈ erase_dup l ↔ a ∈ l :=
by simpa using not_congr (@forall_mem_pw_filter α (≠) _
  (λ x y z xz, not_and_distrib.1 $ mt (and.rec eq.trans) xz) a l)

@[simp] theorem erase_dup_cons_of_mem {a : α} {l : list α} (h : a ∈ l) :
  erase_dup (a::l) = erase_dup l :=
erase_dup_cons_of_mem' $ mem_erase_dup.2 h

@[simp] theorem erase_dup_cons_of_not_mem {a : α} {l : list α} (h : a ∉ l) :
  erase_dup (a::l) = a :: erase_dup l :=
erase_dup_cons_of_not_mem' $ mt mem_erase_dup.1 h

theorem erase_dup_sublist : ∀ (l : list α), erase_dup l <+ l := pw_filter_sublist

theorem erase_dup_subset : ∀ (l : list α), erase_dup l ⊆ l := pw_filter_subset

theorem subset_erase_dup (l : list α) : l ⊆ erase_dup l :=
λ a, mem_erase_dup.2

theorem nodup_erase_dup : ∀ l : list α, nodup (erase_dup l) := pairwise_pw_filter

theorem erase_dup_eq_self {l : list α} : erase_dup l = l ↔ nodup l := pw_filter_eq_self

theorem erase_dup_append (l₁ l₂ : list α) : erase_dup (l₁ ++ l₂) = l₁ ∪ erase_dup l₂ :=
begin
  induction l₁ with a l₁ IH; simp, rw ← IH,
  show erase_dup (a :: (l₁ ++ l₂)) = insert a (erase_dup (l₁ ++ l₂)),
  by_cases a ∈ erase_dup (l₁ ++ l₂);
  [ rw [erase_dup_cons_of_mem' h, insert_of_mem h],
    rw [erase_dup_cons_of_not_mem' h, insert_of_not_mem h]]
end

end erase_dup

/- iota and range -/

/-- `range' s n` is the list of numbers `[s, s+1, ..., s+n-1]`.
  It is intended mainly for proving properties of `range` and `iota`. -/
@[simp] def range' : ℕ → ℕ → list ℕ
| s 0     := []
| s (n+1) := s :: range' (s+1) n

@[simp] theorem length_range' : ∀ (s n : ℕ), length (range' s n) = n
| s 0     := rfl
| s (n+1) := congr_arg succ (length_range' _ _)

@[simp] theorem mem_range' {m : ℕ} : ∀ {s n : ℕ}, m ∈ range' s n ↔ s ≤ m ∧ m < s + n
| s 0     := by simp
| s (n+1) :=
  have m = s → m < s + (n + 1),
    from λ e, e ▸ lt_succ_of_le (le_add_right _ _),
  have l : m = s ∨ s + 1 ≤ m ↔ s ≤ m,
    by simpa [eq_comm] using (@le_iff_eq_or_lt _ _ s m).symm,
  by simp [@mem_range' (s+1) n, or_and_distrib_left, or_iff_right_of_imp this, l]

theorem chain_succ_range' : ∀ s n : ℕ, chain (λ a b, b = succ a) s (range' (s+1) n)
| s 0     := chain.nil _ _
| s (n+1) := (chain_succ_range' (s+1) n).cons rfl

theorem chain_lt_range' (s n : ℕ) : chain (<) s (range' (s+1) n) :=
(chain_succ_range' s n).imp (λ a b e, e.symm ▸ lt_succ_self _)

theorem pairwise_lt_range' : ∀ s n : ℕ, pairwise (<) (range' s n)
| s 0     := pairwise.nil _
| s (n+1) := (chain_iff_pairwise (by exact λ a b c, lt_trans)).1 (chain_lt_range' s n)

theorem nodup_range' (s n : ℕ) : nodup (range' s n) :=
(pairwise_lt_range' s n).imp (λ a b, ne_of_lt)

theorem range'_append : ∀ s m n : ℕ, range' s m ++ range' (s+m) n = range' s (n+m)
| s 0     n := rfl
| s (m+1) n := show s :: (range' (s+1) m ++ range' (s+m+1) n) = s :: range' (s+1) (n+m),
               by rw [add_right_comm, range'_append]

theorem range'_sublist_right {s m n : ℕ} : range' s m <+ range' s n ↔ m ≤ n :=
⟨λ h, by simpa using length_le_of_sublist h,
 λ h, by rw [← nat.sub_add_cancel h, ← range'_append]; apply sublist_append_left⟩

theorem range'_subset_right {s m n : ℕ} : range' s m ⊆ range' s n ↔ m ≤ n :=
⟨λ h, le_of_not_lt $ λ hn, lt_irrefl (s+n) $
  (mem_range'.1 $ h $ mem_range'.2 ⟨le_add_right _ _, nat.add_lt_add_left hn s⟩).2,
 λ h, subset_of_sublist (range'_sublist_right.2 h)⟩

theorem nth_range' : ∀ s {m n : ℕ}, m < n → nth (range' s n) m = some (s + m)
| s 0     (n+1) _ := by simp
| s (m+1) (n+1) h := by simp [nth_range' (s+1) (lt_of_add_lt_add_right h)]

theorem range'_concat (s n : ℕ) : range' s (n + 1) = range' s n ++ [s+n] :=
by rw add_comm n 1; exact (range'_append s n 1).symm

theorem range_core_range' : ∀ s n : ℕ, range_core s (range' s n) = range' 0 (n + s)
| 0     n := rfl
| (s+1) n := by rw [show n+(s+1) = n+1+s, by simp]; exact range_core_range' s (n+1)

theorem range_eq_range' (n : ℕ) : range n = range' 0 n :=
(range_core_range' n 0).trans $ by rw zero_add

@[simp] theorem length_range (n : ℕ) : length (range n) = n :=
by simp [range_eq_range']

theorem pairwise_lt_range (n : ℕ) : pairwise (<) (range n) :=
by simp [range_eq_range', pairwise_lt_range']

theorem nodup_range (n : ℕ) : nodup (range n) :=
by simp [range_eq_range', nodup_range']

theorem range_sublist {m n : ℕ} : range m <+ range n ↔ m ≤ n :=
by simp [range_eq_range', range'_sublist_right]

theorem range_subset {m n : ℕ} : range m ⊆ range n ↔ m ≤ n :=
by simp [range_eq_range', range'_subset_right]

@[simp] theorem mem_range {m n : ℕ} : m ∈ range n ↔ m < n :=
by simp [range_eq_range', zero_le]

@[simp] theorem not_mem_range_self {n : ℕ} : n ∉ range n :=
mt mem_range.1 $ lt_irrefl _

theorem nth_range {m n : ℕ} (h : m < n) : nth (range n) m = some m :=
by simp [range_eq_range', nth_range' _ h]

theorem range_concat (n : ℕ) : range (n + 1) = range n ++ [n] :=
by simp [range_eq_range', range'_concat]

theorem iota_eq_reverse_range' : ∀ n : ℕ, iota n = reverse (range' 1 n)
| 0     := rfl
| (n+1) := by simp [iota, range'_concat, iota_eq_reverse_range' n]

@[simp] theorem length_iota (n : ℕ) : length (iota n) = n :=
by simp [iota_eq_reverse_range']

theorem pairwise_gt_iota (n : ℕ) : pairwise (>) (iota n) :=
by simp [iota_eq_reverse_range', pairwise_lt_range']

theorem nodup_iota (n : ℕ) : nodup (iota n) :=
by simp [iota_eq_reverse_range', nodup_range']

theorem mem_iota {m n : ℕ} : m ∈ iota n ↔ 1 ≤ m ∧ m ≤ n :=
by simp [iota_eq_reverse_range', lt_succ_iff]

@[simp] theorem enum_from_map_fst : ∀ n (l : list α),
  map prod.fst (enum_from n l) = range' n l.length
| n []       := rfl
| n (a :: l) := congr_arg (cons _) (enum_from_map_fst _ _)

@[simp] theorem enum_map_fst (l : list α) :
  map prod.fst (enum l) = range l.length :=
by simp [enum, range_eq_range']

end list
