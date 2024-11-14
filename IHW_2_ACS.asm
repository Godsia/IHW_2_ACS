.data 
prompt_msg: .asciz "\nВведите значение x: "
result_msg: .asciz "Итоговый результат: "
tolerance: .double 0.0005

.text
.globl main

main:
    li a7, 4
    la a0, prompt_msg
    ecall

    li a7, 7
    ecall

    fmv.d f2, fa0           
    
    # Инициализация счётчика
    li t0, 0
    
    j calculate_e  

calculate_e:
    
    # Установка начальных значений:
    fmv.d f4, f2             # f4 = x (входное значение)
    fmv.d f6, f2             # f6 = x (для вычислений e^(-x))

    li t1, 1                   # t1 = 1 (для вычисления e^x)
    fcvt.d.w f8, t1          # f8 = 1.0
    
    fmv.d f10, f4            # f10 = x (для вычисления x^n)
    
    li t3, 1                   # n = 1
    fcvt.d.w f12, t3          # f12 = 1.0 (для вычисления n!)
    
    fld f14, tolerance, t2     # Установка точности 0.0005

# Основной цикл для вычисления e^x по формуле ряда
e_series_loop:
    
    fdiv.d f16, f10, f12      # f16 = x^n / n!
    
    # Проверка условия выхода из цикла
    fle.d t1, f16, f14        # (x^n / n!) <= 0.0005
    fneg.d f14, f14           
    fge.d t2, f16, f14        #(x^n / n!) >= -0.0005
    fneg.d f14, f14           
    beq t1, t2, finalize      

    fadd.d f8, f8, f16        # Добавление текущего члена ряда
    fmul.d f10, f10, f4       # Увеличение степени x
    
    addi t3, t3, 1            # Увеличение n на 1
    fcvt.d.w f14, t3          
    fmul.d f12, f12, f14      # Обновление n!

    j e_series_loop           # Переход к началу цикла

finalize:
    li t5, 1
    addi t4, t4, 1            # Увеличиваем счётчик на 1
    bne t4, t5, record_second_result
    
    fmv.d f18, f8             # Сохранение результата e^x в регистре f18
    
    fmv.d f20, f10            # Возвращаем x в регистр f20 
    fneg.d f20, f20           # Изменяем знак x
    
    j calculate_e             # Переход к повторному вычислению

record_second_result:
    fmv.d f22, f8             # Сохранение результата e^(-x)
    j continue_calculation

continue_calculation:
    fadd.d f22, f18, f22      # Суммируем результаты e^x и e^(-x)
    
    li t1, 2
    fcvt.d.w f24, t1
    fdiv.d f22, f22, f24      # Делим сумму на 2

# Выводим итоговый результат

    li a7, 4                  
    la a0, result_msg
    ecall

    li a7, 3                  
    fmv.d fa0, f22           
    ecall

    li a7, 10
    ecall