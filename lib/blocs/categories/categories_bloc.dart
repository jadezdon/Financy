import 'dart:async';

import 'package:Financy/data/models/account_model.dart';
import 'package:Financy/data/models/transaction_model.dart';
import 'package:Financy/data/repositories/account_repository.dart';
import 'package:Financy/data/repositories/transaction_repository.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

import '../../data/models/category_model.dart';
import '../../data/repositories/category_repository.dart';

part 'categories_event.dart';
part 'categories_state.dart';

class CategoriesBloc extends Bloc<CategoriesEvent, CategoriesState> {
  final CategoryRepository categoryRepository;
  final TransactionRepository transactionRepository;
  final AccountRepository accountRepository;

  CategoriesBloc(
    this.categoryRepository,
    this.transactionRepository,
    this.accountRepository,
  ) : super(CategoriesInitial());

  @override
  Stream<CategoriesState> mapEventToState(CategoriesEvent event) async* {
    if (event is GetCategoriesEvent) {
      yield CategoriesLoading();
      yield* _mapGetCategoriesEventToState(event);
    } else if (event is AddCategoryEvent) {
      yield* _mapAddCategoryEventToState(event);
    } else if (event is UpdateCategoryEvent) {
      yield* _mapUpdateCategoryEventToState(event);
    } else if (event is DeleteCategoryEvent) {
      yield* _mapDeleteCategoryEventToState(event);
    }
  }

  Stream<CategoriesState> _mapGetCategoriesEventToState(GetCategoriesEvent event) async* {
    try {
      List<CategoryModel> categories = await categoryRepository.getAll();
      yield CategoriesLoaded(categories);
    } catch (e) {
      debugPrint(e.toString());
      yield CategoriesNotLoaded();
    }
  }

  Stream<CategoriesState> _mapAddCategoryEventToState(AddCategoryEvent event) async* {
    if (state is CategoriesLoaded) {
      CategoryModel updatedCategory = await categoryRepository.insert(event.category);
      List<CategoryModel> updatedCategories = List<CategoryModel>.from((state as CategoriesLoaded).categories)
        ..add(updatedCategory);
      yield CategoriesLoaded(updatedCategories);
    }
  }

  Stream<CategoriesState> _mapUpdateCategoryEventToState(UpdateCategoryEvent event) async* {
    if (state is CategoriesLoaded) {
      CategoryModel originCategory =
          (state as CategoriesLoaded).categories.firstWhere((element) => element.id == event.category.id);

      if (originCategory.transactionType != event.category.transactionType) {
        //* update accounts' balance
        List<TransactionModel> transactions =
            (await transactionRepository.getAll()).where((element) => element.categoryId == event.category.id).toList();
        List<AccountModel> accounts = await accountRepository.getAll();

        accounts.forEach((account) {
          transactions.forEach((element) {
            if (element.accountId == account.id) {
              if (event.category.transactionType == TransactionType.EXPENSE) {
                account.balance -= (2 * element.amount);
              } else if (event.category.transactionType == TransactionType.INCOME) {
                account.balance += (2 * element.amount);
              }
            }
          });
        });
        await accountRepository.updateAll(accounts);
      }

      await categoryRepository.update(event.category);

      List<CategoryModel> updatedCategories =
          (state as CategoriesLoaded).categories.map((e) => e.id == event.category.id ? event.category : e).toList();
      yield CategoriesLoaded(updatedCategories);
    }
  }

  Stream<CategoriesState> _mapDeleteCategoryEventToState(DeleteCategoryEvent event) async* {
    if (state is CategoriesLoaded) {
      //* update accounts' balance
      List<TransactionModel> transactions =
          (await transactionRepository.getAll()).where((element) => element.categoryId == event.category.id).toList();
      List<AccountModel> accounts = await accountRepository.getAll();

      accounts.forEach((account) {
        transactions.forEach((element) {
          if (element.accountId == account.id) {
            if (event.category.transactionType == TransactionType.EXPENSE) {
              account.balance += element.amount;
            } else if (event.category.transactionType == TransactionType.INCOME) {
              account.balance -= element.amount;
            }
          }
        });
      });

      await accountRepository.updateAll(accounts);

      await transactionRepository.deleteAllByCategoryId(event.category.id);
      await categoryRepository.delete(event.category);

      List<CategoryModel> updatedCategories =
          (state as CategoriesLoaded).categories.where((a) => a.id != event.category.id).toList();
      yield CategoriesLoaded(updatedCategories);
    }
  }
}
