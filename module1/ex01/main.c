/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   main.c                                             :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: rihoy <rihoy@student.42.fr>                +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2026/04/15 20:14:51 by rihoy             #+#    #+#             */
/*   Updated: 2026/04/16 03:09:49 by rihoy            ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#include <avr/io.h>
#include <avr/interrupt.h>

// 15.2.1 Registers
// registre summary
void	timer_init(void)
{
	TCCR1B |= (1 << WGM12);
	TCCR1A |= (1 << COM1A0);
	OCR1A = 7812;
	TCCR1B |= ((1 << CS12) | (1 << CS10));
}

int	main(void) {
	DDRB |= (1 << DDB1);
	timer_init();
	while (1) {}
	return (0);
}
