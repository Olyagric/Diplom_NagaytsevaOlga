
#Если Сервер Или ТолстыйКлиентОбычноеПриложение Или ВнешнееСоединение Тогда

#Область ОбработчикиСобытий

Процедура ОбработкаЗаполнения(ДанныеЗаполнения, ТекстЗаполнения, СтандартнаяОбработка) Экспорт
	
	Ответственный = Пользователи.ТекущийПользователь();
	
	Если ТипЗнч(ДанныеЗаполнения) = Тип("ДокументСсылка.ЗаказПокупателя") Тогда
		ЗаполнитьНаОснованииЗаказаПокупателя(ДанныеЗаполнения);
	КонецЕсли;
	
КонецПроцедуры

Процедура ПередЗаписью(Отказ, РежимЗаписи, РежимПроведения)
	
	Если ОбменДанными.Загрузка Тогда
		Возврат;
	КонецЕсли;

	СуммаДокумента = Товары.Итог("Сумма") + Услуги.Итог("Сумма");
	
КонецПроцедуры

Процедура ОбработкаПроведения(Отказ, Режим)

	Движения.ОбработкаЗаказов.Записывать = Истина;
	Движения.ОстаткиТоваров.Записывать = Истина;
	Движения.ВКМ_ВыставленныеАкты.Записывать = Истина;
	
	Движение = Движения.ОбработкаЗаказов.Добавить();
	Движение.Период = Дата;
	Движение.Контрагент = Контрагент;
	Движение.Договор = Договор;
	Движение.Заказ = Основание;
	Движение.СуммаОтгрузки = СуммаДокумента;

	Для Каждого ТекСтрокаТовары Из Товары Цикл
		Движение = Движения.ОстаткиТоваров.Добавить();
		Движение.ВидДвижения = ВидДвиженияНакопления.Расход;
		Движение.Период = Дата;
		Движение.Контрагент = Контрагент;
		Движение.Номенклатура = ТекСтрокаТовары.Номенклатура;
		Движение.Сумма = ТекСтрокаТовары.Сумма;
		Движение.Количество = ТекСтрокаТовары.Количество;
	КонецЦикла;
	
	// ++Нагайцева О.А. 
	Если  Договор.ВидДоговора = Перечисления.ВидыДоговоровКонтрагентов.ВКМ_АбонентскоеОбслуживание Тогда
		
	Для Каждого ТекСтрокаУслуги Из Услуги Цикл
		Если ТекСтрокаУслуги.Номенклатура = Константы.ВКМ_НоменклатураРаботыСпециалиста.Получить() Тогда
			
		Движение = Движения.ВКМ_ВыставленныеАкты.Добавить();
		Движение.Период = Дата;
		Движение.Клиент = Контрагент;
		Движение.Договор = Договор;
		Движение.НоменклатураУслуги = ТекСтрокаУслуги.Номенклатура;
		Движение.Сумма = ТекСтрокаУслуги.Сумма;
		
		КонецЕсли;
	КонецЦикла;
КонецЕсли;
КонецПроцедуры
 // 
 
#КонецОбласти

#Область СлужебныеПроцедурыИФункции

Процедура ЗаполнитьНаОснованииЗаказаПокупателя(ДанныеЗаполнения)
	
	Запрос = Новый Запрос;
	Запрос.Текст = "ВЫБРАТЬ
	               |	ЗаказПокупателя.Организация КАК Организация,
	               |	ЗаказПокупателя.Контрагент КАК Контрагент,
	               |	ЗаказПокупателя.Договор КАК Договор,
	               |	ЗаказПокупателя.СуммаДокумента КАК СуммаДокумента,
	               |	ЗаказПокупателя.Товары.(
	               |		Ссылка КАК Ссылка,
	               |		НомерСтроки КАК НомерСтроки,
	               |		Номенклатура КАК Номенклатура,
	               |		Количество КАК Количество,
	               |		Цена КАК Цена,
	               |		Сумма КАК Сумма
	               |	) КАК Товары,
	               |	ЗаказПокупателя.Услуги.(
	               |		Ссылка КАК Ссылка,
	               |		НомерСтроки КАК НомерСтроки,
	               |		Номенклатура КАК Номенклатура,
	               |		Количество КАК Количество,
	               |		Цена КАК Цена,
	               |		Сумма КАК Сумма
	               |	) КАК Услуги
	               |ИЗ
	               |	Документ.ЗаказПокупателя КАК ЗаказПокупателя
	               |ГДЕ
	               |	ЗаказПокупателя.Ссылка = &Ссылка";
	
	Запрос.УстановитьПараметр("Ссылка", ДанныеЗаполнения);
	
	Выборка = Запрос.Выполнить().Выбрать();
	
	Если Не Выборка.Следующий() Тогда
		Возврат;
	КонецЕсли;
	
	ЗаполнитьЗначенияСвойств(ЭтотОбъект, Выборка);
	
	ТоварыОснования = Выборка.Товары.Выбрать();
	Пока ТоварыОснования.Следующий() Цикл
		ЗаполнитьЗначенияСвойств(Товары.Добавить(), ТоварыОснования);
	КонецЦикла;
	
	УслугиОснования = Выборка.Услуги.Выбрать();
	Пока ТоварыОснования.Следующий() Цикл
		ЗаполнитьЗначенияСвойств(Услуги.Добавить(), УслугиОснования);
	КонецЦикла;
	
	Основание = ДанныеЗаполнения;
	
КонецПроцедуры


//++ Нагайцева О.А.
Процедура ВКМ_ВыполнитьАвтозаполнение(Объект) Экспорт
	
	НоменклатураАбонентскаяПлата = Константы.ВКМ_НоменклатураАбонентскаяПлата.Получить();
	НоменклатураРаботыСпециалиста = Константы.ВКМ_НоменклатураРаботыСпециалиста.Получить();
	
	Если НЕ ЗначениеЗаполнено(НоменклатураАбонентскаяПлата)ИЛИ НЕ ЗначениеЗаполнено(НоменклатураРаботыСпециалиста)
	Тогда ОбщегоНазначенияКлиентСервер.СообщитьПользователю("Не заполнена Номенклатура");
	Возврат;
	КонецЕсли;
	
	ТабУслуги = Объект.Услуги;
	ТабУслуги.Очистить();
	
	
	ВКМ_ДобавитьАбоненскуюПлату(НоменклатураАбонентскаяПлата, ТабУслуги);
	ВКМ_ДобавитьВыполненныеКлиентуРаботы(НоменклатураРаботыСпециалиста, ТабУслуги);
//	СуммаДокумента = Товары.Итог("Сумма") + Услуги.Итог("Сумма")
КонецПроцедуры


Процедура ВКМ_ДобавитьВыполненныеКлиентуРаботы(НоменклатураРаботыСпециалиста, ТабУслуги)
	
	Запрос = Новый Запрос;
	Запрос.Текст =
		"ВЫБРАТЬ
		|	СУММА(ВКМ_ВыполненныеКлиентуРаботыОбороты.СуммаКОплатеОборот) КАК СуммаКОплате,
		|	СУММА(ВКМ_ВыполненныеКлиентуРаботыОбороты.КоличествоЧасовОборот) КАК КоличествоЧасов,
		|	МИНИМУМ(ВКМ_ВыполненныеКлиентуРаботыОбороты.Договора.ВКМ_СтоимостьЧасаРаботы) КАК ЦенаЧасаРаботы,
		|	ВКМ_ВыполненныеКлиентуРаботыОбороты.Договора.Ссылка Как ДоговорСсылка
		|ИЗ
		|	РегистрНакопления.ВКМ_ВыполненныеКлиентуРаботы.Обороты(&НачалоМесяца, &КонецМесяца, Месяц, Клиент В
		|		(ВЫБРАТЬ
		|			РеализацияТоваровУслуг.Контрагент
		|		ИЗ
		|			Документ.РеализацияТоваровУслуг КАК РеализацияТоваровУслуг
		|		ГДЕ
		|			РеализацияТоваровУслуг.Ссылка = &Ссылка)
		|	И Договора В
		|		(ВЫБРАТЬ
		|			РеализацияТоваровУслуг.Договор
		|		ИЗ
		|			Документ.РеализацияТоваровУслуг КАК РеализацияТоваровУслуг
		|		ГДЕ
		|			РеализацияТоваровУслуг.Ссылка = &Ссылка)) КАК ВКМ_ВыполненныеКлиентуРаботыОбороты
		|СГРУППИРОВАТЬ ПО
		|	ВКМ_ВыполненныеКлиентуРаботыОбороты.Договора,
		|	ВКМ_ВыполненныеКлиентуРаботыОбороты.Договора.Ссылка";
		
	Запрос.УстановитьПараметр("Ссылка", Ссылка);
	Запрос.УстановитьПараметр("НачалоМесяца", НачалоМесяца(Дата));
	Запрос.УстановитьПараметр("КонецМесяца", КонецМесяца(Дата));
	
	РезультатЗапроса = Запрос.Выполнить();
	
	Выборка = РезультатЗапроса.Выбрать();
	
	Пока Выборка.Следующий() Цикл
//	Если Не ЗначениеЗаполнено(Основание) Тогда
//		Основание = Выборка.ДоговорСсылка;
//		КонецЕсли;
	НоваяСтрока = ТабУслуги.Добавить();
	НоваяСтрока.Номенклатура = НоменклатураРаботыСпециалиста;
	НоваяСтрока.Количество = Выборка.КоличествоЧасов;
	НоваяСтрока.Цена = Выборка.ЦенаЧасаРаботы;
	НоваяСтрока.Сумма = Выборка.СуммаКОплате;
	КонецЦикла;
	
	
КонецПроцедуры

Процедура ВКМ_ДобавитьАбоненскуюПлату(НоменклатураАбонентскаяПлата, ТабУслуги)
		
АбонентскаяПлата= Договор.ПолучитьОбъект();
СуммаАбонентскойПлаты = АбонентскаяПлата.ВКМ_СуммаАбонентскойПлаты;
	Если СуммаАбонентскойПлаты = 0 Тогда
		Возврат;
	КонецЕсли;	
	
		НоваяСтрокаТЧ = ТабУслуги.Добавить();
	    НоваяСтрокаТЧ.Номенклатура = НоменклатураАбонентскаяПлата;
	    НоваяСтрокаТЧ.Количество = 1;
	    НоваяСтрокаТЧ.Цена = СуммаАбонентскойПлаты;
	    НоваяСтрокаТЧ.Сумма = НоваяСтрокаТЧ.Цена*НоваяСтрокаТЧ.Количество;
    
КонецПроцедуры
    
//--
#КонецОбласти
#КонецЕсли
