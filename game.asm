################################################################
#                                                              #
#       Lucas Araujo Pena - 130056162                          #
#                                                              #
#       Jogo da vida em Assembly RISC-V                        #
#                                                              #
#                                                              #
################################################################
.data
################################################################

mat1: .byte                         # Matriz inicial
 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 
 0 1 1 0 0 0 1 0 0 0 0 0 0 0 0 0 
 0 1 1 0 0 0 0 1 0 0 0 0 0 0 0 0 
 0 0 0 0 0 1 1 1 0 0 0 0 0 0 0 0 
 0 0 0 0 0 0 0 0 0 0 0 1 1 1 0 0 
 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 
 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 
 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 
 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 
 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 
 0 0 0 1 1 0 0 0 0 0 1 1 1 0 0 0 
 0 0 1 1 0 0 0 0 0 0 0 1 0 0 0 0 
 0 0 0 1 0 0 0 0 0 0 0 0 0 0 0 0 
 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 
 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 
 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 

mat2: .byte 0:255                   # Matriz de swap

red:            .word 0xCC0000      # Vermelho
black:          .word 0x333333      # Fundo
display:        .word 0x3000        # Inicio do display


################################################################
.text
################################################################

main:

    ##      Definicao de valores            ##

    la      s0, mat1            # s0 -> Matriz 1
    la      s1, mat2            # s1 -> Matriz 2

    lw      s2, display         # s2 -> Inicio do display
    lw      s3, red             # s3 -> Vermelho
    lw      s4, black           # s4 -> Preto 

    mv      a0, s0              # Movendo a Matriz inicial para a0
    call    plot_m              # Mostra o estado inicial

loop:

    li      a7, 32              # Codigo para utilizar o Sleep
    li      a0, 300             # Tempo de Sleem em milisegundos
    ecall                       # Realiza o Sleep

    call    next_gen            # Chama a funcao de gerar a proxima matriz

    mv      a0, s0              # Copia Matriz 1
    mv      a1, s1	        # Copia Matriz 2

    call    update_m            # Chama a subrotina de atualizacao

    mv      a0, s0              # Copia a nova matriz

    call    plot_m              # Chama a subrotina de mostrar os pixeis

    j       loop                # Mantem a execucao no loop

    li      a7, 10              # Codigo para finalizacao do programa
    ecall                       # Chamada de Sistema

################################################################
#                Funcoes de Plot de Matriz                     #
################################################################

plot_m:

    li      a5, 1               # Contador de Linhas
    li      a6, 1               # Contador de colunas
    li      s9, 17              # Offset de uma linha

    mv      a4, s2              # Copiando o endereco do display
    
plot_m1:

    beq     a6, s9, plot_m2
    addi    a4, a4, 4           # Proximo passo do Display
    lb      t0, 0( a0 )         # Verifica o valor do pixel
    addi    a0, a0, 1           # Anda com a Matriz

    sw      s4, -4( a4 )        # Descolorindo o pixel
    addi    a6, a6, 1
    beqz    t0, plot_m1

    sw      s3, -4( a4 )        # Colore o pixel

    j       plot_m1             # Retorna para o comeco do loop

plot_m2:

    beq     a5, s9, funct_end   # Termina o loop no final
    li      a6, 1               # 
    addi    a5, a5, 1           # Proxima linha

    j       plot_m1

################################################################
#                   Gerando o proximo passo                    #  
################################################################

next_gen:

    li      a5, 1               # Contador para linhas
    li      a6, 1               # Contador para colunas
    
    mv      a4, s0              # Copia Matriz 1
    mv      s8, s1              # Copia Matriz 2

next_gen_2:

    beq     a6, s9, next_gen_3  # Vai para a proxima coluna quando necessario

    addi    sp, sp, -4          # Criando espaco na pilha
    sw      ra, 0(sp)           # Salvando o endereco de Retorno
    call    live_or_die         # Decide se vive ou morre

    lw      ra, 0(sp)
    addi    sp, sp, 4           # Desempilha
    sb      a7, 0(s8)           # Retorna se vive ou morre

    addi    a4, a4, 1           # Avanca na Matriz 1
    addi    s8, s8, 1           # Acanca na Matriz 2
    addi    a6, a6, 1           #

    j       next_gen_2          # Continua no Loop

next_gen_3:

    beq     a5, s9, funct_end   # Termina o loop
    addi    a5, a5, 1           # Avanca para a proxima linha
    
    li      a6, 1               # Volta para a primeira coluna

    j       next_gen_2          # Retorna pro loop    

################################################################
#                       Vive ou morre                          #
################################################################

live_or_die:

    mv      a2, s0              # Move a matriz 1
    li      a7, 0               # Numero de vivos

    addi    sp, sp, -4          # Salvando RA na pilha
    sw      ra, 0(sp)

################################################################
#   Checa os vizinhos da celula:
#
#       - Os 2 primeiros 'addi' fornecem o endereco do vizinho.
#       - 
################################################################

vizinho1:

	mv  	a2, s0 

	addi	a0, a5, -1            
	addi	a1, a6, -1
	call 	read
	beqz	a3, vizinho2
	addi	a7, a7, 1

vizinho2:

	mv	    a2, s0

	addi	a0, a5, -1
	addi	a1, a6, 0
	call 	read
	beqz	a3, vizinho3
	addi	a7, a7, 1

vizinho3:

	mv	    a2, s0

	addi	a0, a5, -1
	addi	a1, a6, 1
	call 	read
	beqz	a3, vizinho4
	addi	a7, a7, 1

vizinho4:

	mv	    a2, s0

	addi	a0, a5, 0
	addi	a1, a6, -1
	call 	read
	beqz	a3, vizinho5
	addi	a7, a7, 1

vizinho5:

	mv	    a2, s0

	addi	a0, a5, 0
	addi	a1, a6, 1
	call 	read
	beqz	a3, vizinho6
	addi	a7, a7, 1

vizinho6:

	mv	    a2, s0

	addi	a0, a5, 1
	addi	a1, a6, -1
	call 	read
	beqz	a3, vizinho7
	addi	a7, a7, 1

vizinho7:

	mv	    a2, s0

	addi	a0, a5, 1
	addi	a1, a6, 0
	call 	read
	beqz	a3, vizinho8
	addi	a7, a7, 1

vizinho8:

	mv  	a2, s0

	addi	a0, a5, 1
	addi	a1, a6, 1
	call 	read
	beqz	a3, vizinho_end
	addi	a7, a7, 1

vizinho_end:

    li      t0, 2
    li      t1, 3
    lw      ra, 0(sp)           # Recupera o RA da pilha
    addi    sp, sp, 4
    beq     t1, a7, live        # Checa condicao de vida

    mv      a0, a5
    mv      a1, a6
    mv      a2, s0              # Copia a Matriz 1

    addi    sp, sp, -4          # Alocando espaco na pilha
    sw      ra, 0(sp)           # Salvando RA na pilha

    call    read

    lw      ra, 0(sp)           # Restaurando da pilha
    addi    sp, sp, 4           # Liberando espaco na pilha

    beqz    a3, die             # Checa condicao de morte

    beq     t0, a7, live

die:

    li      a7, 0               # Morrera na proxima iteracao
    ret

live:

    li      a7, 1               # Vivera na proxima iteracao
    ret

################################################################
#                    Atualizacao das matrizes
################################################################

update_m:

    li      a5, 1               # Contador de linhas
    li      a6, 1               # Contador de colunas
    li      s9, 17              # Numero de colunas por linha

update_m1:

    beq     a6, s9, update_m2
    lb      t0, 0(a1)           #
    sb      t0, 0(a0)

    addi    a0, a0, 1           # Percorre na Matriz 1
    addi    a1, a1, 1           # Percorre na Matriz 2
    addi    a6, a6, 1

    j       update_m1

update_m2:

    beq     a5, s9, funct_end   # Finaliza o loop
    li      a6, 1               # Volta para a primeira coluna
    addi    a5, a5, 1           # Avanca para a proxima linha

    j       update_m1           # Retorna para o primero loop
    
################################################################
#                           Leitura
################################################################

read:

    li      t1, 0
    li      t2, 17

    ## Verificando se o vizinho esta na Matriz ##
    bge     a0, t2, out_of_bounds
    bge     a1, t2, out_of_bounds
    ble     a0, t1, out_of_bounds
    ble     a1, t1, out_of_bounds

    j       read1               # Comeca a Leitura
    
out_of_bounds:

    li      a3, 0
    ret

read1:

    ## Percorrendo a coluna
    addi    a1, a1, -1 
    beqz    a1, read2
    addi    a2, a2, 1

    j       read1             # Retorna para o loop

read2:

    ## Percorrendo a linha
    addi    a0, a0, -1
    beqz    a0, read_end
    li      a1, 17

    j       read1           # Retorna para o loop
    
read_end:

    lb      a3, 0(a2)       # Colorindo o pixel
    ret

################################################################
#                        Auxiliares                            #
################################################################

funct_end:

    ret                         # Retorna para onde estava
