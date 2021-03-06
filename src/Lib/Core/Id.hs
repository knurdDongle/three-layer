{-# LANGUAGE DeriveAnyClass     #-}

-- | Contains newtype safe wrappers.

module Lib.Core.Id
       ( -- * Id
         Id (..)
       , AnyId
       , castId
       ) where

import Data.Aeson (FromJSON, ToJSON)
import Database.PostgreSQL.Simple.FromField (FromField)
import Database.PostgreSQL.Simple.ToField (ToField)
import Elm (ElmType)
import Web.HttpApiData (FromHttpApiData)

-- | Wrapper for textual id. Contains phantom type parameter for increased type-safety.
newtype Id a = Id { unId :: UUID }
    deriving stock (Show, Generic)
    deriving newtype (Eq, Ord, Hashable, FromField, ToField, FromHttpApiData)
    deriving anyclass (FromJSON, ToJSON, ElmType)

-- | When we don't care about type of 'Id' but don't want to deal with type variables
type AnyId = Id ()

-- | Unsafe cast of 'Id'. Use with explicit TypeApplication.
castId :: forall to from . Id from -> Id to
castId (Id a) = Id a
