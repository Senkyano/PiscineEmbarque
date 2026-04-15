/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   main.c                                             :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: rihoy <rihoy@student.42.fr>                +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2026/04/13 17:46:18 by rihoy             #+#    #+#             */
/*   Updated: 2026/04/15 19:46:25 by rihoy            ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#include <avr/io.h>
#include <util/delay.h>

/*
*	DDRx definition du pin en mode input ou output 1=output 0=input
*	DDRB = 0xFF mettre tous les B en mode output
*	PORTB |= (1 << PORTB0) on change le bit speficique a PB0 de des ports B
*/

int	main(void)
{
	DDRB = 0xFF;
	PORTB |= (1 << PORTB0);
	return (0);
}
