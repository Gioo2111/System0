extends Node

class_name Colors
const LETTER_COLOR := Color(0.5, 0.0, 0.5)      # Roxo (letras)
const NUMBER_COLOR := Color(0.0, 0.3, 0.7)      # Azul (números)

## Cores de feedback
const CORRECT := Color(0.0, 1.0, 0.0)           # Verde (correto e na posição)
const PRESENT := Color(1.0, 1.0, 0.0)           # Amarelo (correto, posição errada)
const ABSENT := Color(0.3, 0.3, 0.3)            # Cinza (não está na senha)

## Outros (opcional)
const BG_COLOR := Color(0.05, 0.05, 0.05)       # Fundo geral (estética "terminal")
const TEXT_COLOR := Color(1.0, 1.0, 1.0)        # Cor do texto padrão
